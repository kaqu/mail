//
//  Mailbox.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 19/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

//import Foundation
//
//public struct Config {
//    public let hostname: String
//    public let port: UInt16
//    public let login: String
//    public let password: String
////    public let connectionType: TLS
//    
//    static func icloud(login: String, password: String) -> Config {
//        return Config.init(hostname: "imap.mail.me.com", port: 993, login: login, password: password)
//    }
//}
//
//public struct Mailbox {
//    public let config: Config
//    
//    
//    public func getFoldersList(completion: () -> [String]) {
//        
//    }
//}
//
//import Network
//
//public struct MailConnector {
//    let hostname: String
//    let port: String
//    
//    public init(hostname: String, port: String) {
//        self.hostname = hostname
//        self.port = port
//    }
//    
//    public func connect() {
//        let tlsConf = NWProtocolTLS.Options.init()
//        let params = NWParameters.init(tls: tlsConf)
//        let interface = NWInterface.InterfaceType.wifi
//        let endpoint = NWEndpoint.service(name: "imap", type: "imap", domain: hostname, interface: nil)
//        let conn = NWConnection.init(to: endpoint, using: params)
//        
//        
//        conn.start(queue: DispatchQueue.global())
//        conn.receiveMessage { (data, ctx, bool, err) in
//            guard let data = data else {
//                return print("ERR")
//            }
//            guard let str = String.init(data: data, encoding: .utf8) else {
//                return print("ERR")
//            }
//            print(str)
//        }
//    }
//}
