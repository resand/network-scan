//
//  NetworkSavedViewController.swift
//  RedScan
//
//  Created by René Sandoval on 16/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class NetworkSavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    let configApp = ConfigApp()
    
    fileprivate var networkListData = [Network]()
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //This is how you remove the text for the back button that will go back to this view
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkListData = Network.findAll()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        table.reloadData()
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        if segmentControl.selectedSegmentIndex == 0 {
            networkListData = Network.find("type=\"\(TypeNetwork.home.rawValue)\"")
        } else if segmentControl.selectedSegmentIndex == 1 {
            networkListData = Network.find("type=\"\(TypeNetwork.office.rawValue)\"")
        } else {
            networkListData = Network.findAll()
        }
        
        table.reloadData()
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if networkListData.count == 0 {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        
        return networkListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MGSwipeTableCell
        
        let network = self.networkListData[indexPath.row]
        
        //configure rights button
        cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"icon-home.png"), backgroundColor: UIColor(hexString: configApp.colorMain)) {
            (sender: MGSwipeTableCell!) -> Bool in
            self.setNetworkType(type: TypeNetwork.home.rawValue, network: network)
            return true
            },
            MGSwipeButton(title: "", icon: UIImage(named:"icon-office.png"), backgroundColor: UIColor(hexString: configApp.colorMain)) {
            (sender: MGSwipeTableCell!) -> Bool in
            self.setNetworkType(type: TypeNetwork.office.rawValue, network: network)
            return true
            }
        ]
        cell.leftSwipeSettings.transition = .border
        
        cell.textLabel?.text = network.name
        cell.detailTextLabel?.text = network.mac
        
        return cell
    }
    
    fileprivate func setNetworkType(type: Int16, network: Network) {
        network.type = type
        network.save()
        
        UserDefaults.standard.set(type, forKey: network.name!)
        UserDefaults.standard.synchronize()
        
        table.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailNetwork" {
            if let indexPath = self.table.indexPathForSelectedRow {
                let networkDetail: Network = networkListData[indexPath.row]
                
                let destinationController = segue.destination as! DevicesTableViewController
                destinationController.networkDetail = networkDetail as Network
            }
        }
    }
}
