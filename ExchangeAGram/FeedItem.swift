//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Anup on 04/01/2015.
//  Copyright (c) 2015 Anup. All rights reserved.
//

import Foundation
import CoreData

/*
*
* Step 10 - Create a new entity via xcdatamodeld interface
* then create a NSManagedObject via Editor. Then annotate it
* with objc
*/
@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
