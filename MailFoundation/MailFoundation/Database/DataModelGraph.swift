//
//  DataModelGraph.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation
import CoreData

class DataModelGraph {
    
    internal let modelVersion: DataModel.Version
    private var entityDescriptions: [NSEntityDescription] = []
    private var managedObjectTypes: [DataObject.Type] = []
    
    internal init(version: DataModel.Version) {
        self.modelVersion = version
    }
    
    internal var entityNames: [String] {
        return entityDescriptions.map { $0.name! }
    }
    
    internal func entityDescription<ObjectType: DataObject>(for type: ObjectType.Type) -> NSEntityDescription {
        let name = ObjectType.entityName
        
        for entityDescription in entityDescriptions where entityDescription.name == name {
            return entityDescription
        }
        
        let entityDescription = ObjectType.entityDescription(in: self)
        entityDescriptions.append(entityDescription)
        managedObjectTypes.append(type)
        return entityDescription
    }
    
    internal func managedObject(withEntityName entityName: String) -> NSManagedObject.Type {
        for type in managedObjectTypes where type.entityName == entityName {
            return type
        }
        
        fatalError("Missing managed object type with entity name: \(entityName)")
    }
}
