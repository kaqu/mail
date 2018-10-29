//
//  IMAPMessages.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 27/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation

internal struct IMAPError {
    internal let info: String
}

internal struct IMAPMailMessage {
    internal let header: IMAPMailMessageHeader
    internal let content: [IMAPMailMessageContent]
    internal let attachments: [Data]
}

internal struct IMAPMailMessageHeader {
    internal let uid: String
    internal let subject: String
    internal let sender: String
    internal let recipients: [String]
    internal let copyRecipients: [String]
}

internal enum IMAPMailMessageContent {
    case plain(String)
    case html(String)
}

internal struct IMAPMailBoxStatus {
    
}

internal struct IMAPStatus {
    internal let totalMessageCount: UInt
    internal let recentMessageCount: UInt
    internal let flags: [String]
    internal let validityUID: String
}

internal struct IMAPSearchResult {
    
}
