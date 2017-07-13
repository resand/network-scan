//
//  Network+CoreDataProperties.swift
//  RedScan
//
//  Created by René Sandoval on 21/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import Foundation
import CoreData


extension Network {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Network> {
        return NSFetchRequest<Network>(entityName: "Network")
    }

    @NSManaged public var mac: String?
    @NSManaged public var maker: String?
    @NSManaged public var name: String?
    @NSManaged public var type: Int16
    @NSManaged public var devices: NSSet?

}

// MARK: Generated accessors for devices
extension Network {

    @objc(addDevicesObject:)
    @NSManaged public func addToDevices(_ value: DeviceNetwork)

    @objc(removeDevicesObject:)
    @NSManaged public func removeFromDevices(_ value: DeviceNetwork)

    @objc(addDevices:)
    @NSManaged public func addToDevices(_ values: NSSet)

    @objc(removeDevices:)
    @NSManaged public func removeFromDevices(_ values: NSSet)

}
