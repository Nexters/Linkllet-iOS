//
//  CDFolder+CoreDataProperties.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/10/07.
//
//

import Foundation
import CoreData


extension CDFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFolder> {
        return NSFetchRequest<CDFolder>(entityName: "CDFolder")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var articles: NSOrderedSet?

}

// MARK: Generated accessors for articles
extension CDFolder {

    @objc(insertObject:inArticlesAtIndex:)
    @NSManaged public func insertIntoArticles(_ value: CDArticle, at idx: Int)

    @objc(removeObjectFromArticlesAtIndex:)
    @NSManaged public func removeFromArticles(at idx: Int)

    @objc(insertArticles:atIndexes:)
    @NSManaged public func insertIntoArticles(_ values: [CDArticle], at indexes: NSIndexSet)

    @objc(removeArticlesAtIndexes:)
    @NSManaged public func removeFromArticles(at indexes: NSIndexSet)

    @objc(replaceObjectInArticlesAtIndex:withObject:)
    @NSManaged public func replaceArticles(at idx: Int, with value: CDArticle)

    @objc(replaceArticlesAtIndexes:withArticles:)
    @NSManaged public func replaceArticles(at indexes: NSIndexSet, with values: [CDArticle])

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: CDArticle)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: CDArticle)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSOrderedSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSOrderedSet)

}

extension CDFolder : Identifiable {

}
