//
//  DataModel.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation
import CoreData

internal final class DataModel {
    
    internal typealias Version = UInt
    
    internal static let currentVersion: Version = 1
    
    internal static var current: DataModel {
        return DataModel(version: currentVersion)
    }
    
    internal let version: Version
    
    internal let managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        model.versionIdentifiers = ["\(currentVersion)"]
        return model
    }()
    
    private let graph: DataModelGraph
    
    internal init(version: Version) {
        self.version = version
        self.graph = DataModelGraph(version: version)
        setUpEntities()
    }
    
    private func setUpEntities() {
        let entities: [NSEntityDescription] = allEntitiesDescriptions()
        
        precondition(validate(entities: entities, in: graph))
        
        managedObjectModel.entities = entities
    }
    
    private func validate(entities: [NSEntityDescription], in graph: DataModelGraph) -> Bool {
        var entityNames = graph.entityNames
        
        for entity in entities {
            guard let name = entity.name else {
                fatalError("Name missing for entity: \(entity)")
            }
            
            guard let index = entityNames.index(of: name) else {
                print("Entity \(name) is in entities list but not in the data model grah!")
                return false
            }
            
            entityNames.remove(at: index)
        }
        
        if entityNames.count > 0 {
            print("Entities: \(entityNames) are missing from the entity list but found in the data model graph!")
            return false
        }
        
        return true
    }
    
    private func allEntitiesDescriptions() -> [NSEntityDescription] {
        return [
            graph.entityDescription(for: MailboxDataObject.self),
            graph.entityDescription(for: MessageDataObject.self),
        ]
    }
}
