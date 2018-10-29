//
//  Mailbox.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation

public struct Mailbox {
    
    public var name: String
    public private(set) var messages: [Message.UID]
    
    public init(name: String) {
        self.name = name
        self.messages = []
    }
}

import CoreData

@objc(MailboxDataObject)
internal final class MailboxDataObject : DataObject {
    
    @NSManaged internal var name: String
    @NSManaged internal var messages: Set<MessageDataObject>
    
    internal static func entityDescription(in graph: DataModelGraph) -> NSEntityDescription {
        switch graph.modelVersion {
        case _:
            return NSEntityDescription()
                .adding(attribute: \MailboxDataObject.name, type: .string)
                .adding(relationship: \MailboxDataObject.messages, entity: MessageDataObject.entityDescription(in: graph))
        }
    }
}
