//
//  Task+CoreDataProperties.swift
//  OneLabTodo
//
//  Created by Alikhan Abutalipov on 1/10/21.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String
    @NSManaged public var note: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completionDate: Date?
    @NSManaged public var creationDate: Date

}

extension Task : Identifiable {

}
