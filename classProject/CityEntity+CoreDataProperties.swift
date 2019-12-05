//
//  CityEntity+CoreDataProperties.swift
//  classProject
//
//  Created by Jacquelin Huang on 11/20/19.
//  Copyright © 2019 Jacquelin Huang. All rights reserved.
//
//

import Foundation
import CoreData


extension CityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityEntity> {
        return NSFetchRequest<CityEntity>(entityName: "CityEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var picture: Data?
    @NSManaged public var lat: Double?
    @NSManaged public var lng: Double?
}
