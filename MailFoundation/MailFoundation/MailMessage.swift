//
//  MailMessage.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 20/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation

let messageDateFormatter = DateFormatter.init()

public typealias MailAddress = String

public struct Message {
    public let id: UID
    public var date: Date
    public var from: MailAddress
    public var to: [MailAddress]
    public var subject: String
    public var flags: [Flag]
    public var content: Content
    
    internal init(id: UID, date: Date, from: MailAddress, to: [MailAddress], subject: String, flags: [Flag], content: Content = .notFetched) {
        self.id = id
        self.date = date
        self.from = from
        self.to = to
        self.subject = subject
        self.flags = flags
        self.content = content
    }
    
    // TODO: to complete, fix etc
    internal static func make(from rawMessage: String) -> Message? {
        return nil
//        var makeId: ID?
//        var makeDate: Date?
//        var makeFrom: String?
//        var makeTo: [String]?
//        var makeSubject: String?
//        var makeContent: Content?
//        //        var multipartBoundary = ""
//        var iterator = rawMessage.split(separator: " ").makeIterator()
//        while let word = iterator.next() {
//            switch word {
//            case "UID":
//                guard let id = iterator.next() else { return nil }
//                makeId = String(id)
//            case "Date:":
//                var dateString = ""
//                while let datePart = iterator.next() {
//                    guard datePart != "\n" else { break }
//                    dateString += datePart
//                }
//                guard let date = messageDateFormatter.date(from: String(dateString)) else { return nil }
//                makeDate = date
//            case "Subject:":
//                guard let subject = iterator.next() else { return nil }
//                makeSubject = String(subject)
//            case "From:":
//                var fromString = ""
//                while let fromPart = iterator.next() {
//                    guard fromPart != "\n" else { break }
//                    fromString += fromPart
//                }
//                makeFrom = fromString
//            case "To:":
//                var toString = ""
//                while let toPart = iterator.next() {
//                    guard toPart != "\n" else { break }
//                    toString += toPart
//                }
//                makeTo = [toString]
//            case _: break
//            }
//        }
//        makeContent = .notFetched
//
//        guard let id = makeId else { return nil }
//        guard let date = makeDate else { return nil }
//        guard let from = makeFrom else { return nil }
//        guard let to = makeTo else { return nil }
//        guard let subject = makeSubject else { return nil }
//        guard let content = makeContent else { return nil }
//
//        return Message.init(id: id, date: date, from: from, to: to, subject: subject, content: content)
    }
}

extension Message {
    
    public typealias UID = String
    
    public enum Flag : String {
        case answered = "\\Answered"
        case flagged = "\\Flagged"
        case draft = "\\Draft"
        case deleted = "\\Deleted"
        case seen = "\\Seen"
    }
    
    public enum Content {
        case notFetched
        case plainText(String)
    }
}

extension Message {
    
    
}
