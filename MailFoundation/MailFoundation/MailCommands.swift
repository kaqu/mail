//
//  MailCommand.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 20/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

internal protocol MailCommand {
    var commandString: String { get }
}

internal struct MailCommandTag : Hashable {
    
    private let prefix: String
    private var number: UInt
    
    internal init(prefix: String, number: UInt = 0) {
        self.prefix = prefix
        self.number = number
    }
    
    internal mutating func getAndIterate() -> MailCommandTag {
        let current = number
        number += 1
        return MailCommandTag.init(prefix: prefix, number: current)
    }
    
    internal var commandString: String {
        return "\(prefix)\(number)"
    }
}

public enum MailConnectionCommand {
    // info
    case capability
    
    // auth
    case loginPlain(user: String, password: String)
    case logout
    
    // idle
    case check
    case noop
}

extension MailConnectionCommand : MailCommand {
    
    internal var commandString: String {
        switch self {
        case .capability:
            return "CAPABILITY"
        case let .loginPlain(user, password):
            return "LOGIN \(user) \(password)"
        case .logout:
            return "LOGOUT"
        case .check:
            return "CHECK"
        case .noop:
            return "NOOP"
        }
    }
}

public enum MailBoxCommand {
    // mailbox manipulation
    case select(mailbox: String) // read-write
    case examine(mailbox: String) // read only
    case create(mailbox: String)
    case delete(mailbox: String)
    case rename(mailbox: String, to: String)
    
    // mailbox subscription
    case subscribe(mailbox: String)
    case unsubscribe(mailbox: String)
    
    // mailbox list
    case list(reference: String, mailbox: String)
    case listSubscribed(reference: String, mailbox: String)
    
    // mailbox status
    case status(mailbox: String, [StatusItem])
    
    // cleanup
    case expunge
}

extension MailBoxCommand : MailCommand {
    
    internal var commandString: String {
        switch self {
        case let .select(mailbox):
            return "SELECT \"\(mailbox)\""
        case let .examine(mailbox):
            return "EXAMINE \"\(mailbox)\""
        case let .create(mailbox):
            return "CREATE \"\(mailbox)\""
        case let .delete(mailbox):
            return "DELETE \"\(mailbox)\""
        case let .rename(mailbox, newName):
            return "RENAME \"\(mailbox)\" \"\(newName)\""
        case let .subscribe(mailbox):
            return "SUBSCRIBE \"\(mailbox)\""
        case let .unsubscribe(mailbox):
            return "UNSUBSCRIBE \"\(mailbox)\""
        case let .list(reference, mailbox):
            return "LIST \"\(reference)\" \"\(mailbox.isEmpty ? "%" : mailbox)\""
        case let .listSubscribed(reference, mailbox):
            return "LSUB \(reference) \"\(mailbox.isEmpty ? "*" : mailbox)\""
        case let .status(mailbox, items):
            return "STATUS \"\(mailbox)\" (\(items.isEmpty ? StatusItem.validityUID.rawValue : items.map { $0.rawValue }.joined(separator: ", ")))"
        case .expunge:
            return "EXPUNGE"
        }
    }
}

extension MailBoxCommand {
    
    public enum StatusItem : String {
        case messages = "MESSAGES"
        case recent = "RECENT"
        case unseen = "UNSEEN"
        case nextUID = "UIDNEXT"
        case validityUID = "UIDVALIDITY"
    }
}

public enum MailMessageCommand {
    case search([SearchCriteria])
    case fetch(Message.UID, items: [MessageItem])
}

extension MailMessageCommand : MailCommand {
    
    internal var commandString: String {
        switch self {
        case let .search(criteria):
            return "UID SEARCH \(criteria.isEmpty ? "ALL" : criteria.map { $0.commandString }.joined(separator: " "))"
        case let .fetch(uid, items):
            return "UID FETCH \(uid) \(items.isEmpty ? "BODY[]" : "(" + items.map { $0.commandString }.joined(separator: " ") + ")")"
        }
    }
}

extension MailMessageCommand {
    public enum SearchCriteria { // TODO: ...
        case answered
        case bcc(String)
    }
    
    public enum MessageItem {
        case uid
        case flags
        case envelope
        case internalDate
        case bodyStructure
        case body([BodyItem])
    }
}

extension MailMessageCommand.MessageItem {
    
    internal var commandString: String {
        switch self {
        case .uid:
            return "UID"
        case .flags:
            return "FLAGS"
        case .envelope:
            return "ENVELOPE"
        case .internalDate:
            return "INTERNALDATE"
        case .bodyStructure:
            return "BODYSTRUCTURE"
        case let .body(items):
            return "BODY[\(items.map { $0.commandString }.joined(separator: " "))]"
        }
    }
    
    public enum BodyItem {
        case header([HeaderField])
        case text
    }
}

extension MailMessageCommand.MessageItem.BodyItem {
    
    internal var commandString: String {
        switch self {
        case let .header(fields):
            return fields.isEmpty ? "HEADER" : "HEADER.FIELDS (\(fields.map { $0.rawValue }.joined(separator: " ")))"
        case .text:
            return "TEXT"
        }
    }
    
    public enum HeaderField : String {
        case dateFrom = "DATE FROM"
    }
}

extension MailMessageCommand.SearchCriteria {
    internal var commandString: String {
        switch self {
        case .answered:
            return "ANSWERED"
        case let .bcc(string):
            return "BCC \(string)"
        }
    }
}
