//
//  MailConnection.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 20/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Network
import Futura

internal final class MailConnection {
    private let workQueue = DispatchQueue.init(label: "MailConnectionWorker")
    private let connection: NWConnection
    private var nextCommandTag: MailCommandTag = .init(prefix: "A")
    
    private let stateChannel = Channel<NWConnection.State>()
    internal var stateStream: Futura.Stream<NWConnection.State> {
        return stateChannel.stream
    }
    private let eventsChannel = Channel<Data>()
    internal var eventsStream: Futura.Stream<Data> {
        return eventsChannel.stream
    }
    
    public init(host: NWEndpoint.Host, port: NWEndpoint.Port = .imaps) {
        let tlsConfig = NWProtocolTLS.Options.init()
        let parameters = NWParameters.init(tls: tlsConfig)
        self.connection = NWConnection.init(host: host, port: port, using: parameters)
        setup()
    }
    
    private func setup() {
        connection.stateUpdateHandler = {
            self.stateChannel.broadcast($0)
        }
        stateStream.next {
            switch $0 {
            case .ready:
                self.readNext()
            case _: break
            }
        }
        connection.start(queue: workQueue)
    }
    
    private func readNext(buffer: Data? = nil) {
        guard case .ready = self.connection.state else { return }
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 9999, completion: { (data, ctx, completed, error) in
            guard error == nil else {
                return self.eventsChannel.broadcast(error!)
            }
            guard let data = data else { return }
            if let ctx = ctx {
                if ctx.isFinal {
                    if var buffer = buffer {
                        buffer.append(data)
                        self.eventsChannel.broadcast(buffer)
                    } else {
                        self.eventsChannel.broadcast(data)
                    }
                    return self.readNext(buffer: nil)
                } else {
                    if var buffer = buffer {
                        buffer.append(data)
                        return self.readNext(buffer: buffer)
                    } else {
                        return self.readNext(buffer: data)
                    }
                }
            } else if completed {
                if var buffer = buffer {
                    buffer.append(data)
                    self.eventsChannel.broadcast(buffer)
                } else {
                    self.eventsChannel.broadcast(data)
                }
                return self.readNext(buffer: nil)
            } else {
                return self.readNext(buffer: buffer)
            }
        })
    }
    
    public func send(mailCommand: MailConnectionCommand) {
        send(mailCommand)
    }
    
    public func send(mailBoxCommand: MailBoxCommand) {
        send(mailBoxCommand)
    }
    
    public func send(mailMessageCommand: MailMessageCommand) {
        send(mailMessageCommand)
    }
    
    internal func send(_ command: MailCommand) {
        let tag = nextCommandTag.getAndIterate()
        let command = tag.commandString + " " + command.commandString + "\n"
        print(command)
        connection.send(content: command.data(using: .utf8), completion: .contentProcessed({ (error) in
            guard let error = error else { return }
            return self.eventsChannel.broadcast(error)
        }))
    }
}
