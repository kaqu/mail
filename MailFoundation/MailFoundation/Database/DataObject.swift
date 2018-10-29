//
//  DataObject.swift
//  MailFoundation
//
//  Created by Kacper Kaliński on 29/10/2018.
//  Copyright © 2018 Kaqu. All rights reserved.
//

import Foundation
import CoreData

typealias DataObject = NSManagedObject & DatabaseEntity

extension NSManagedObject {
    
    internal static var entityName: String {
        return self.entity().name!
    }
}

internal protocol DatabaseEntity {
    static func entityDescription(in graph: DataModelGraph) -> NSEntityDescription
}
