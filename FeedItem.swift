//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Anup on 08/01/2015.
//  Copyright (c) 2015 Anup. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData

}
