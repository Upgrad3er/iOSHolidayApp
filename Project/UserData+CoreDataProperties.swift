//
//  UserData+CoreDataProperties.swift
//  Project
//
//  Created by Axel Nyberg on 09/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UserData {

    @NSManaged var password: String?
    @NSManaged var userName: String?

}
