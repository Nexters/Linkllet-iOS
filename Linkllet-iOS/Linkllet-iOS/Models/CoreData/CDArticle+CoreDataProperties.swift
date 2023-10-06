//
//  CDArticle+CoreDataProperties.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/10/07.
//
//

import Foundation
import CoreData


extension CDArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDArticle> {
        return NSFetchRequest<CDArticle>(entityName: "CDArticle")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var url: URL?
    @NSManaged public var createAt: Date?

}

extension CDArticle : Identifiable {

}
