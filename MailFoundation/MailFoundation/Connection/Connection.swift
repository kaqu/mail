//
//  Connection.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 27/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation

internal enum ConnectionEvent {
    case connecting
    case connectionEstablished
    case connectionEnded
    case connectionFailed(Error)
    case message(String)
    case data(Data)
    case error(Error)
}
