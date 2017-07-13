//
//  DevicesTableViewController.swift
//  RedScan
//
//  Created by René Sandoval on 17/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class DevicesTableViewController: UITableViewController {

    // MARK: - Properties

    var networkDetail: Network!
    var devices : [DeviceNetwork]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = networkDetail.name
        
        devices = networkDetail.devices?.allObjects as! [DeviceNetwork]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Function for UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if devices.count == 0 {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DeviceCustomTableViewCell
        
        let device = devices[indexPath.row]
        
        //Border color trust device
        let isDeviceTrust = UserDefaults.standard.bool(forKey: device.mac!)
        
        if isDeviceTrust {
            cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.green, thickness: 7.0)
            
            //configure left button
            cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"icon-remove.png"), backgroundColor: .red) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.unSetDeviceTrust(mac: device.mac!)
                return true
            }]
            cell.leftSwipeSettings.transition = .border
            cell.leftButtons.removeAll()
        } else {
            cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.white, thickness: 7.0)

            //configure left button
            cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"icon-check.png"), backgroundColor: .green) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.setDeviceTrust(mac: device.mac!)
                return true
            }]
            cell.leftSwipeSettings.transition = .border
            cell.rightButtons.removeAll()
        }
        
        cell.ipLabel.text = device.ip
        cell.macLabel.text = device.mac == "02:00:00:00:00:00" ? "Mi equipo" : device.mac
        cell.hostnameLabel.text = device.name
        cell.makerLabel.text = device.maker
        
        return cell
    }
    
    fileprivate func setDeviceTrust(mac: String) {
        UserDefaults.standard.set(true, forKey: mac)
        UserDefaults.standard.synchronize()
        
        self.tableView.reloadData()
    }
    
    fileprivate func unSetDeviceTrust(mac: String) {
        UserDefaults.standard.set(false, forKey: mac)
        UserDefaults.standard.synchronize()
        
        self.tableView.reloadData()
    }
}
