//
//  MailCommand.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 20/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

internal protocol ConnectionCommand {
    var commandString: String { get }
}

internal extension ConnectionCommand {
    func command(with tag: CommandTag) -> Data? {
        return "\(tag.commandString) \(self.commandString)\n".data(using: .utf8)
    }
}

internal struct CommandTag : Hashable {
    
    private let prefix: String
    private var number: UInt
    
    internal init(prefix: String = "#", number: UInt = 0) {
        self.prefix = prefix
        self.number = number
    }
    
    internal mutating func getAndIterate() -> CommandTag {
        let current = number
        number += 1
        return CommandTag.init(prefix: prefix, number: current)
    }
    
    internal var commandString: String {
        return "\(prefix)\(number)"
    }
}
