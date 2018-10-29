//
//  MailMessage.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 20/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation

public typealias MailAddress = String

public struct Message {
    public let uid: UID
    public var header: Header
    public var content: [Content]
    public var attachments: [Data]
}

extension Message {
    
    public typealias UID = String
    
    public struct Header {
        internal var subject: String
        internal var sender: MailAddress
        internal var recipients: [MailAddress]
        internal var copyRecipients: [MailAddress]
        internal var date: Date
        internal var flags: [Flag]
    }
    
    public enum Flag {
        case answered
        case flagged
        case draft
        case deleted
        case seen
        case custom(String)
    }
    
    public enum Content {
        case plain(String)
        case html(String)
    }
}

extension Message.Flag {
    
    internal var raw: String {
        switch self {
        case .answered:
            return "\\Answered"
        case .flagged:
            return "\\Flagged"
        case .draft:
            return "\\Draft"
        case .deleted:
            return "\\Deleted"
        case .seen:
            return "\\Seen"
        case let .custom(flag):
            return flag
        }
    }
}

import CoreData

@objc(MessageDataObject)
internal final class MessageDataObject : DataObject {
    
    @NSManaged internal var uid: Message.UID
    
    internal static func entityDescription(in graph: DataModelGraph) -> NSEntityDescription {
        switch graph.modelVersion {
        case _:
            return NSEntityDescription()
                .adding(attribute: \MessageDataObject.uid, type: .string)
        }
    }
}
