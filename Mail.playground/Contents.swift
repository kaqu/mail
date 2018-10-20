import Foundation
import Network
import Futura

public struct MailboxAddress {
    var user: String
    var domain: String
}

public struct MailboxMessageInfo {
    public var date: Date
    public var from: MailboxAddress
    public var to: [MailboxAddress]
    public var subject: String
    public var id: String
}

public struct MailboxMessage {
    public var info: MailboxMessageInfo
    public var content: Content
    
    public enum Content {
        case plainText(String)
    }
}

public enum MailboxInfo {
    //    case capability(String)
    case undefined(String)
}

public enum MailboxCommand {
    case raw(String)
    
    case capability
    case noop
    //    case authenticate(String)
    case login(user: String, password: String)
    case select(mailbox: String) // read-write
    case examine(mailbox: String) // read only
    case create(mailbox: String)
    case delete(mailbox: String)
    case rename(mailbox: String, to: String)
    case subscribe(mailbox: String)
    case unsubscribe(mailbox: String)
    case list(reference: String, mailbox: String)
    case listSubscribed(reference: String, mailbox: String)
    case status(mailbox: String, [StatusItem])
    case append(mailbox: String, flags: [String], message: String)
    case check
    case expunge
    case search([SearchCriteria])
    case idSearch([SearchCriteria])
    case fetch(message: String, items: [MessageItem])
    case idFetch(messageID: String, items: [MessageItem])
    case close
    case logout
}

extension MailboxCommand {
    
    public enum StatusItem : String {
        case messages = "MESSAGES"
        case recent = "RECENT"
        case uidNext = "UIDNEXT"
        case uidValidity = "UIDVALIDITY"
        case unseen = "UNSEEN"
    }
    
    public enum SearchCriteria : String { // TODO: ...
        case all = "ALL"
        case unread = "KEYWORD SEEN"
    }
    
    public enum MessageItem : String {
        case id = "UID"
        case flags = "FLAGS"
        case envelope = "ENVELOPE"
        case internalDate = "INTERNALDATE"
        case body = "BODY"
        case bodyStructure = "BODYSTRUCTURE"
    }
    
    var commandString: String {
        switch self {
        case let .raw(message):
            return message
        case let .login(user, password):
            return "LOGIN \(user) \(password)"
        case .capability:
            return "CAPABILITY"
        case .noop:
            return "NOOP"
        case let .select(mailbox):
            return "SELECT \(mailbox)"
        case let .examine(mailbox):
            return "EXAMINE \(mailbox)"
        case let .create(mailbox):
            return "CREATE \(mailbox)"
        case let .delete(mailbox):
            return "DELETE \(mailbox)"
        case let .rename(mailbox, newName):
            return "RENAME \(mailbox) \(newName)"
        case let .subscribe(mailbox):
            return "SUBSCRIBE \(mailbox)"
        case let .unsubscribe(mailbox):
            return "UNSUBSCRIBE \(mailbox)"
        case let .list(reference, mailbox):
            return "LIST \"\(reference)\" \"\(mailbox.isEmpty ? "%" : mailbox)\""
        case let .listSubscribed(reference, mailbox):
            return "LSUB \(reference) \(mailbox.isEmpty ? "*" : mailbox)"
        case let .status(mailbox, items):
            return "STATUS \(mailbox) (\(items.map { $0.rawValue }.joined(separator: ", ")))"
        case let .append(mailbox, flags, _):
            return "APPEND \(mailbox) (\(flags.joined(separator: ", "))"
        case .check:
            return "CHECK"
        case .expunge:
            return "EXPUNGE"
        case let .search(criteria):
            return "SEARCH \(criteria.isEmpty ? "ALL" : criteria.map { $0.rawValue }.joined(separator: " "))"
        case let .idSearch(criteria):
            return "UID SEARCH \(criteria.isEmpty ? "ALL" : criteria.map { $0.rawValue }.joined(separator: " "))"
        case .close:
            return "CLOSE"
        case .logout:
            return "LOGOUT"
        case let .fetch(message, items):
            return "FETCH \(message) \(items.isEmpty ? "RFC822" : "(" + items.map { $0.rawValue }.joined(separator: " ") + ")")"
        case let .idFetch(messageID, items):
            return "UID FETCH \(messageID) \(items.isEmpty ? "RFC822" : "(" + items.map { $0.rawValue }.joined(separator: " ") + ")")"
        }
    }
}

internal struct MailboxCommandTag : Hashable {
    
    private let prefix: String
    private var number: UInt
    
    internal init(prefix: String, number: UInt = 0) {
        self.prefix = prefix
        self.number = number
    }
    
    internal mutating func getAndIterate() -> MailboxCommandTag {
        let current = number
        number += 1
        return MailboxCommandTag.init(prefix: prefix, number: current)
    }
    
    internal var commandString: String {
        return "\(prefix)\(number)"
    }
}

internal final class MailboxConnection {
    private let mailboxQueue = DispatchQueue.init(label: "MailboxConnectionWorker")
    private let connection: NWConnection
    private let state = Channel<NWConnection.State>()
    internal var stateStream: Futura.Stream<NWConnection.State> {
        return state.stream
    }
    private let read = Channel<Data>()
    internal var readStream: Futura.Stream<Data> {
        return read.stream
    }
    private var pendingCommands: [MailboxCommandTag:Promise<MailboxInfo>] = [:]
    private var nextCommandTag: MailboxCommandTag = .init(prefix: "A")
    
    internal init(host: NWEndpoint.Host, port: NWEndpoint.Port = .imaps) {
        let tlsConfig = NWProtocolTLS.Options.init()
        let parameters = NWParameters.init(tls: tlsConfig)
        self.connection = NWConnection.init(host: host, port: port, using: parameters)
    }
    
    internal func setup(completion: @escaping () -> Void) {
        connection.stateUpdateHandler = {
            self.state.broadcast($0)
        }
        state.next { (state) in
            guard case .ready = state else { return }
            self.readNext()
        }
        connection.start(queue: mailboxQueue)
    }
    
    private func readNext() {
        self.connection.receive(minimumIncompleteLength: 0, maximumLength: 99999, completion: { (data, ctx, completed, error) in
            if let error = error {
                self.read.broadcast(error)
            } else if let data = data {
                self.read.broadcast(data)
                if let string = String.init(data: data, encoding: .utf8) {
                    self.pendingCommands.keys.forEach({ (tag) in
                        guard string.hasPrefix(tag.commandString) else { return }
                        self.pendingCommands[tag]?.fulfill(with: MailboxInfo.undefined(string))
                        self.pendingCommands[tag] = nil
                    })
                }
            } else {
                //
            }
            guard case .ready = self.connection.state else { return }
            self.readNext()
        })
    }
    
    @discardableResult
    internal func send(command: MailboxCommand) -> Future<MailboxInfo> {
        let promise = Promise<MailboxInfo>()
        let tag = nextCommandTag.getAndIterate()
        let command = tag.commandString + " " + command.commandString + "\n"
        print(command)
        connection.send(content: command.data(using: .utf8), completion: NWConnection.SendCompletion.contentProcessed({ (error) in
            if let error = error {
                promise.break(with: error)
            } else {
                self.pendingCommands[tag] = promise
            }
        }))
        return promise.future
    }
    
    //    internal func send(string: String) -> Future<String> {
    //        let promise = Promise<String>()
    //        connection.send(content: string.data(using: .utf8), completion: NWConnection.SendCompletion.contentProcessed({ (error) in
    //            if let error = error {
    //                self.read.broadcast(error)
    //                promise.break(with: error)
    //            } else {
    //                self.readNext()
    //                promise.fulfill(with: "Sent: \(string)")
    //            }
    //        }))
    //        return promise.future
    //    }
    //
    //    internal func connect(withLogin login: String, password: String) -> Futura.Stream<Data> {
    //        connection.send(content: "LOGIN \(login) \(password)".data(using: .utf8), completion: NWConnection.SendCompletion.contentProcessed({ (error) in
    //            if let error = error {
    //                self.read.broadcast(error)
    //            } else {
    //                self.readNext()
    //            }
    //        }))
    //        return readStream
    //    }
    
    deinit {
        connection.cancel()
    }
}
