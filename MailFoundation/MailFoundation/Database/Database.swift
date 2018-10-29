//
//  Database.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation
import CoreData

internal final class Database {
    private let accessQueue: DispatchQueue = .init(label: "mail.database")
    private let config: DatabaseConfig
    internal let managedObjectContext: NSManagedObjectContext
    
    internal init(with config: DatabaseConfig) {
        self.config = config
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: DataModel.current.managedObjectModel)
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: config.databaseURL, options: nil)
        } catch {
            fatalError()
        }
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        self.managedObjectContext = context
    }
}

