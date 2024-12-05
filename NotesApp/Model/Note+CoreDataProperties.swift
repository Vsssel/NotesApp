//
//  Note+CoreDataProperties.swift
//  
//
//  Created by Assel Artykbay on 05.12.2024.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var addedDate: Date?
    @NSManaged public var title: String?

}
