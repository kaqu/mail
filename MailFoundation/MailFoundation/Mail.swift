//
//  Mail.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 27/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation
import Network
import Futura

public final class Mail {
    private let config: MailConfig
    private let database: Database
    private var state: MailState
    private var promises: [CommandTag: Promise<Data>] = [:]
    private lazy var imapConnection: IMAPConnection = {
        IMAPConnection.init(host: NWEndpoint.Host(config.imapHostname), port: NWEndpoint.Port(rawValue: config.imapPort) ?? .smtp, eventHandler: { [weak self] (event) in
            guard let self = self else { return }
            switch event { // TODO: data race
            case .connecting:
                break
            case .connectionEstablished:
                break
            case .connectionEnded:
                self.promises.forEach { $0.value.cancel() }
                self.promises = [:]
                break
            case let .connectionFailed(error):
                self.promises.forEach { $0.value.break(with: error) }
                self.promises = [:]
                break
            case let .message(string):
                break
            case let .data(data):
                break
            case let .error(error):
                break
            }
        })
    }()
    
    public init(with config: MailConfig) {
        self.config = config
        self.database = Database.init(with: DatabaseConfig.init(identifier: config.login))
        self.state = MailState.init(uid: "", mailboxes: [])
    }
    
    public func fetchContent(of message: Message.UID) -> Future<Message> {
        let promise = Promise<Message>()
        
        return promise.future
    }
    
    public func fetchMessags(from mailbox: Mailbox) -> Future<[Message]> {
        let promise = Promise<[Message]>()
        
        return promise.future
    }
    
    public func fetchMailboxes() -> Future<[Mailbox]> {
        let promise = Promise<[Mailbox]>()
        imapConnection.send(IMAPMailBoxCommand.list(reference: "", mailbox: ""))
        return promise.future
    }
}

public struct MailConfig {
    public var imapHostname: String
    public var imapPort: UInt16
    public var smtpHostname: String
    public var smtpPort: UInt16
    public var login: String
    public var password: String
}

public extension MailConfig {
    
    static func icloud(login: String, password: String) -> MailConfig {
        return MailConfig.init(imapHostname: "imap.mail.me.com", imapPort: 993, smtpHostname: "???", smtpPort: 0, login: login, password: password)
    }
    
    static func wp_pl(login: String, password: String) -> MailConfig {
        return MailConfig.init(imapHostname: "imap.wp.pl", imapPort: 993, smtpHostname: "???", smtpPort: 0, login: login, password: password)
    }
}

internal struct MailState {
    internal var uid: String
    internal var mailboxes: [Mailbox]
}
