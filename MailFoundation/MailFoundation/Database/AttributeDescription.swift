//
//  AttributeDescription.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation
import CoreData

extension NSEntityDescription {
    
    @discardableResult
    func adding<Object: DataObject, T>(attribute keyPath: KeyPath<Object, T>,
             type: AttributeType,
             defaultValue: T? = nil) -> Self {
        let description = NSAttributeDescription()
        description.name = NSExpression.init(forKeyPath: keyPath).keyPath
        description.attributeType = type.coreType
        description.isOptional = false
        description.defaultValue = defaultValue
        
        properties.append(description)
        return self
    }
    
    @discardableResult
    func adding<Object: DataObject, T: DataObject>(relationship keyPath: KeyPath<Object, Set<T>>,
                                                   entity: NSEntityDescription, allowEmpty: Bool = true) -> Self {
        let description = NSRelationshipDescription()
        description.name = NSExpression.init(forKeyPath: keyPath).keyPath
        description.destinationEntity = entity
        description.deleteRule = .cascadeDeleteRule
        description.isOptional = false
        description.minCount = allowEmpty ? 0 : 1
        description.maxCount = 0
        
        properties.append(description)
        return self
    }
    
    @discardableResult
    func adding<Object: DataObject, T: DataObject>(oneToOneRelationship keyPath: KeyPath<Object, T>,
             entity: NSEntityDescription) -> Self {
        let description = NSRelationshipDescription()
        description.name = NSExpression.init(forKeyPath: keyPath).keyPath
        description.destinationEntity = entity
        description.deleteRule = .cascadeDeleteRule
        description.isOptional = true
        description.minCount = 0
        description.maxCount = 1
        
        properties.append(description)
        return self
    }
}

enum AttributeType {
    case int16
    case int32
    case int64
    case decimal
    case double
    case float
    case string
    case boolean
    case date
    case binary
    case transformable
    case objectID
    
    var coreType: NSAttributeType {
        switch self {
        case .int16:
            return .integer16AttributeType
        case .int32:
            return .integer32AttributeType
        case .int64:
            return .integer64AttributeType
        case .decimal:
            return .decimalAttributeType
        case .double:
            return .doubleAttributeType
        case .float:
            return .floatAttributeType
        case .string:
            return .stringAttributeType
        case .boolean:
            return .booleanAttributeType
        case .date:
            return .dateAttributeType
        case .binary:
            return .binaryDataAttributeType
        case .transformable:
            return .transformableAttributeType
        case .objectID:
            return .objectIDAttributeType
        }
    }
}
