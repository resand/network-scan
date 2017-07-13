//
//  NetworkHelper.swift
//  RedScan
//
//  Created by René Sandoval on 16/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import SystemConfiguration.CaptiveNetwork

internal class BSSID {
    class func fetchBSSIDInfo() ->  String {
        var currentBSSID = ""
        if let interfaces:CFArray = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if unsafeInterfaceData != nil {
                    let interfaceData = unsafeInterfaceData! as Dictionary!
                    for dictData in interfaceData! {
                        if dictData.key as! String == "BSSID" {
                            currentBSSID = dictData.value as! String
                        }
                    }
                }
            }
        }
        return currentBSSID
    }
}
