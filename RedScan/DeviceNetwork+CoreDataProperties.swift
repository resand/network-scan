//
//  DeviceNetwork+CoreDataProperties.swift
//  RedScan
//
//  Created by René Sandoval on 21/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import Foundation
import CoreData


extension DeviceNetwork {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceNetwork> {
        return NSFetchRequest<DeviceNetwork>(entityName: "DeviceNetwork")
    }

    @NSManaged public var ip: String?
    @NSManaged public var mac: String?
    @NSManaged public var maker: String?
    @NSManaged public var name: String?
    @NSManaged public var network: Network?

}
