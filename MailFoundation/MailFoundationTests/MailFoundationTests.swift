//
//  MailFoundationTests.swift
//  MailFoundationTests
//
//  Created by Kacper Kaliński on 19/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import XCTest
@testable import MailFoundation

class MailFoundationTests: XCTestCase {

    
    func testExample() {
        let lock = NSLock.init()
        lock.lock()
        DispatchQueue.global().async {
            let conn = MailConnection.init(host: "imap.mail.me.com")
            conn.eventsStream
                .next { (data) in
                    let str = String.init(data: data, encoding: .utf8) ?? "???"
                    print(str)
                    guard let message = Message.make(from: str) else { return }
                    print(message)
            }
            sleep(2)
            conn.send(mailCommand: .loginPlain(user: "kaqukal@icloud.com", password: "dnfr-nmtw-quxe-rhfy"))
            sleep(2)
            conn.send(mailCommand: .noop)
            sleep(2)
            conn.send(mailCommand: .capability)
            sleep(2)
            conn.send(mailBoxCommand: .select(mailbox: "INBOX"))
            sleep(2)
            conn.send(mailCommand: .capability)
            sleep(2)
            conn.send(mailBoxCommand: .list(reference: "", mailbox: ""))
            sleep(2)
            conn.send(mailBoxCommand: .status(mailbox: "INBOX", []))
            sleep(2)
            conn.send(mailBoxCommand: .status(mailbox: "INBOX", [MailBoxCommand.StatusItem.messages]))
            sleep(2)
            conn.send(mailMessageCommand: .search([MailMessageCommand.SearchCriteria.answered]))
            sleep(2)
            conn.send(mailMessageCommand: .fetch("410", items: [MailMessageCommand.MessageItem.envelope, MailMessageCommand.MessageItem.flags]))
            sleep(2)
            conn.send(mailBoxCommand: .select(mailbox: "Sent Messages"))
            sleep(2)
            conn.send(mailMessageCommand: .fetch("411", items: [.body([])]))
            sleep(2)
            conn.send(mailBoxCommand: .select(mailbox: "INBOX"))
            sleep(2)
            conn.send(mailMessageCommand: .fetch("412", items: [MailMessageCommand.MessageItem.body([])]))
            
//            conn.setup { }
//            sleep(2)
//            conn.send(command: .noop)
//            sleep(2)
//            conn.send(command: .login(user: "kaqukal@icloud.com", password: "dnfr-nmtw-quxe-rhfy"))
//            sleep(2)
//            conn.send(command: .select(mailbox: "INBOX"))
//            sleep(2)
//            conn.send(command: .list(reference: "", mailbox: ""))
//            sleep(2)
//            conn.send(command: .raw("SEARCH AFTER \"01-Jan-2013\""))
//            sleep(2)
//            conn.send(command: .search([.all]))
//            sleep(2)
//            conn.send(command: .search([.unread]))
//            sleep(2)
//            conn.send(command: .idSearch([]))
//            sleep(2)
//            conn.send(command: .fetch(message: "1", items: [.id, .flags, .body, .bodyStructure, .envelope, .internalDate]))
//            sleep(2)
//            conn.send(command: .idFetch(messageID: "410", items: []))
//            sleep(2)
//            conn.send(command: .noop)
//            sleep(2)
//            conn.send(command: .raw("UID FETCH 410 (RFC822)"))
//            sleep(2)
//            conn.send(command: .raw("UID FETCH 410 (BODY.PEEK[])"))
//            sleep(2)
//            conn.send(command: .noop)
            sleep(60)
            conn.send(mailCommand: .logout)
            sleep(2)
            lock.unlock()
        }
        lock.lock()
    }

}
