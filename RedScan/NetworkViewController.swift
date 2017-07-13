//
//  NetworkViewController.swift
//  RedScan
//
//  Created by René Sandoval on 11/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import UIKit
import LNRSimpleNotifications
import MGSwipeTableCell
import SwiftyJSON

class NetworkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MainPresenterDelegate {

    // MARK: - Properties
    
    let configApp = ConfigApp()
    
    private var myContext = 0
    var presenter: MainPresenter!
    
    let notificationManagerSuccess = LNRNotificationManager()
    let notificationManagerError = LNRNotificationManager()
    
    var networkSaved: Network? = nil

    @IBOutlet weak var labelTitleNetwork: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainPresenter(delegate: self)
        addObserversForKVO()
        
        configView()
        configNotification()
        
        //Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(NetworkViewController.update(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let typeNetwork = UserDefaults.standard.integer(forKey: presenter.ssidName())
        
        if typeNetwork == Int(TypeNetwork.home.rawValue) {
            title = "Red - Casa"
        } else if typeNetwork == Int(TypeNetwork.office.rawValue){
            title = "Red - Oficina"
        } else {
            title = "Red"
        }
        
        table.reloadData()
    }
    
    //MARK: - KVO Observers
    func addObserversForKVO ()->Void {
        presenter.addObserver(self, forKeyPath: "connectedDevices", options: .new, context:&myContext)
        presenter.addObserver(self, forKeyPath: "progressValue", options: .new, context:&myContext)
        presenter.addObserver(self, forKeyPath: "isScanRunning", options: .new, context:&myContext)
    }
    
    func removeObserversForKVO ()->Void {
        presenter.removeObserver(self, forKeyPath: "connectedDevices")
        presenter.removeObserver(self, forKeyPath: "progressValue")
        presenter.removeObserver(self, forKeyPath: "isScanRunning")
    }
    
    fileprivate func configView() {
        let nameNetwork = presenter.ssidName()
        
        activityIndicator.isHidden = true
        labelTitleNetwork.textColor = UIColor(hexString: configApp.colorMain)
        labelTitleNetwork.text = nameNetwork == "No WiFi Available" ? "No hay red WiFi disponible" : presenter.ssidName()
    }
    
    @IBAction func update(_ sender: UIBarButtonItem) {
        networkSaved = Network.findOne("mac=\"\(presenter.bssid())\"")
        presenter.connectedDevices.removeAll()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        labelTitleNetwork.text = presenter.ssidName()
        presenter.scanButtonClicked()
    }

    // MARK: - Function for UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.connectedDevices!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DeviceCustomTableViewCell
        
        let device = presenter.connectedDevices[indexPath.row]

        //Border color trust device
        let isDeviceTrust = UserDefaults.standard.bool(forKey: device.macAddress)
        
        if isDeviceTrust {
            cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.green, thickness: 7.0)
            
            //configure left button
            cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"icon-remove.png"), backgroundColor: .red) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.unSetDeviceTrust(mac: device.macAddress)
                return true
            }]
            cell.leftSwipeSettings.transition = .border
            cell.leftButtons.removeAll()
        } else {
            cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.white, thickness: 7.0)

            //configure left button
            cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"icon-check.png"), backgroundColor: .green) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.setDeviceTrust(mac: device.macAddress)
                return true
            }]
            cell.leftSwipeSettings.transition = .border
            cell.rightButtons.removeAll()
        }
        
        cell.ipLabel.text = device.ipAddress
        cell.macLabel.text = device.macAddress == "02:00:00:00:00:00" ? "Mi equipo" : device.macAddress
        cell.hostnameLabel.text = device.hostname
        cell.makerLabel.text = device.brand
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    fileprivate func setDeviceTrust(mac: String) {
        UserDefaults.standard.set(true, forKey: mac)
        UserDefaults.standard.synchronize()
        
        self.table.reloadData()
    }
    
    fileprivate func unSetDeviceTrust(mac: String) {
        UserDefaults.standard.set(false, forKey: mac)
        UserDefaults.standard.synchronize()
        
        self.table.reloadData()
    }
    
    //MARK: - Presenter Delegates
    
    func mainPresenterIPSearchFinished() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        saveDevices()
        notificationManagerSuccess.showNotification(notification: LNRNotification(title: "Escaneo finalizado", body: "Hay \(presenter.connectedDevices.count) dispositivos conectados a la red WiFi", duration: LNRNotificationDuration.default.rawValue, onTap: nil, onTimeout: nil))
    }
    
    func mainPresenterIPSearchCancelled() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        self.table.reloadData()
    }
    
    func mainPresenterIPSearchFailed() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        notificationManagerError.showNotification(notification: LNRNotification(title: "Error al escanear", body: "Debe estar conectado a un red WiFi", duration: LNRNotificationDuration.default.rawValue, onTap: nil, onTimeout: nil))
    }
    
    //MARK: - Save network in CoreData
    
    func saveDevices() {
        if networkSaved != nil {
            if (networkSaved?.devices!.count)! > 0 {
                for device in (networkSaved?.devices!)! {
                    (device as! DeviceNetwork).destroy()
                }
            }
            
            for device in presenter.connectedDevices {
                let newDeviceNetwork: DeviceNetwork = DeviceNetwork.new()
                newDeviceNetwork.ip = device.ipAddress
                newDeviceNetwork.mac = device.macAddress
                newDeviceNetwork.maker = device.brand
                newDeviceNetwork.name = device.hostname
                
                networkSaved?.addToDevices(newDeviceNetwork)
            }
            networkSaved?.save()
        } else {
            let network: Network = Network.new()
            network.mac = presenter.bssid()
            network.name = presenter.ssidName()
            
            if presenter.connectedDevices.count > 0 {
                for device in presenter.connectedDevices {
                    let newDeviceNetwork: DeviceNetwork = DeviceNetwork.new()
                    newDeviceNetwork.ip = device.ipAddress
                    newDeviceNetwork.mac = device.macAddress
                    newDeviceNetwork.maker = device.brand
                    newDeviceNetwork.name = device.hostname
                    
                    network.addToDevices(newDeviceNetwork)
                }
            }
            
            network.save()
        }
    }

    //MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &myContext) {
            switch keyPath! {
            case "connectedDevices":
                table.reloadData()
            case "progressValue": break
                //print(self.presenter.progressValue)
            case "isScanRunning":
                let isScanRunning = change?[.newKey] as! BooleanLiteralType
                updateButton.image = isScanRunning ? #imageLiteral(resourceName: "icon-cancel") : #imageLiteral(resourceName: "icon-update")
            default:
                print("Not valid key for observing")
            }
        }
    }
    
    //MARK: - Deinit
    deinit {
        self.removeObserversForKVO()
    }
    
    fileprivate func configNotification() {
        // Configure notification success
        notificationManagerSuccess.notificationsPosition = LNRNotificationPosition.top
        notificationManagerSuccess.notificationsBackgroundColor = UIColor(hexString: configApp.colorSecondary)
        notificationManagerSuccess.notificationsTitleTextColor = UIColor.white
        notificationManagerSuccess.notificationsBodyTextColor = UIColor.white
        notificationManagerSuccess.notificationsSeperatorColor = UIColor.white
        
        // Configure notification error
        notificationManagerError.notificationsPosition = LNRNotificationPosition.top
        notificationManagerError.notificationsBackgroundColor = UIColor.red
        notificationManagerError.notificationsTitleTextColor = UIColor.white
        notificationManagerError.notificationsBodyTextColor = UIColor.white
        notificationManagerError.notificationsSeperatorColor = UIColor.white
    }
}
