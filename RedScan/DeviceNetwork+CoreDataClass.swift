//
//  DeviceNetwork+CoreDataClass.swift
//  RedScan
//
//  Created by René Sandoval on 16/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelper


public class DeviceNetwork: NSManagedObject, CDHelperEntity {
    public static var entityName: String! { return "DeviceNetwork" }
}
