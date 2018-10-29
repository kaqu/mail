//
//  DatabaseConfig.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation


internal struct DatabaseConfig {
    
    internal let databaseURL: URL
    
    internal init(identifier: String) {
        precondition(identifier.isEmpty, "Database identifier cannot be empty")
        self.databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(identifier).db")
    }
}


