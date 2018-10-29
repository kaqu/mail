//
//  IMAPConnection.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 20/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Network
import Futura

internal final class IMAPConnection {
    private let workQueue: DispatchQueue = .init(label: "mail.connection.imap")
    private let connection: NWConnection
    private var nextCommandTag: CommandTag = .init()
    private let eventHandler: (ConnectionEvent) -> Void
    
    internal init(host: NWEndpoint.Host, port: NWEndpoint.Port = .imaps, eventHandler: @escaping (ConnectionEvent) -> Void) {
        let tlsConfig: NWProtocolTLS.Options = .init()
        let parameters: NWParameters = .init(tls: tlsConfig)
        self.connection = .init(host: host, port: port, using: parameters)
        self.eventHandler = eventHandler
        setup()
    }
    
    internal func connectIfNeeded() {
        workQueue.sync {
            switch connection.state {
            case .waiting, .preparing, .ready:
                break
            case .failed, .cancelled:
                nextCommandTag = .init()
                connection.restart()
            case .setup:
                nextCommandTag = .init()
                connection.start(queue: workQueue)
            }
        }
    }
    
    internal func disconnect() {
        workQueue.sync {
            connection.cancel()
        }
    }
    
    private func setup() {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .setup:
                break
            case .waiting, .preparing:
                self.eventHandler(.connecting)
            case .ready:
                self.eventHandler(.connectionEstablished)
                self.read()
            case let .failed(error):
                self.eventHandler(.connectionFailed(error))
            case .cancelled:
                self.eventHandler(.connectionEnded)
            }
        }
    }
    
    private func read(with buffer: Data? = nil) {
        guard case .ready = self.connection.state else { return }
        self.connection.receive(minimumIncompleteLength: 2, maximumLength: 4096, completion: { [weak self] (data, ctx, completed, error) in
            guard let self = self else { return }
            guard error == nil else {
                self.eventHandler(.error(error!))
                return self.read()
            }
            guard let data = data else {
                return self.read()
            }
            if ctx?.isFinal ?? completed {
                if var buffer = buffer {
                    buffer.append(data)
                    if let string = String(data: buffer, encoding: .utf8) {
                        self.eventHandler(.message(string))
                    } else {
                        self.eventHandler(.data(buffer))
                    }
                } else {
                    if let string = String(data: data, encoding: .utf8) {
                        self.eventHandler(.message(string))
                    } else {
                        self.eventHandler(.data(data))
                    }
                }
                self.read()
            } else {
                if var buffer = buffer {
                    buffer.append(data)
                    self.read(with: buffer)
                } else {
                    self.read(with: data)
                }
            }
        })
    }
    
    internal func send(_ command: IMAPCommand) -> CommandTag {
        let tag = nextCommandTag.getAndIterate()
        connection.send(content: command.command(with: tag), completion: .contentProcessed({ (error) in
            guard let error = error else { return }
            self.eventHandler(.error(error))
        }))
        return tag
    }
}
