//
//  ViewController.swift
//  ISSPassCodingChallenge
//
//  Created by Kiyoshi Woolheater on 3/13/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    // declare properties
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpTable()
        requestUserLocation()
        callAPI()
    }
    
    // set up table view
    func setUpTable() {
        table.delegate = self
        table.dataSource = self
        // add refresh control to table
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshControl
        } else {
            table.addSubview(refreshControl)
        }
        // configure refresh control
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
    }

    // asks to use users location
    func requestUserLocation() {
        // ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // for use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        // if yes then location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.getUserLocation()
        }
    }
    
    // gets the users location from core location
    func getUserLocation() {
        self.currentLocation = (locationManager.location?.coordinate)!
    }
    
    // call client to populate the backend array - if successful reload table
    func callAPI() {
        Client.sharedInstance().callAPI(latitude: String(describing: currentLocation.latitude), longitude: String(describing: currentLocation.longitude)) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    // action for refresh control
    @objc private func refreshTableView(_ sender: Any) {
        PassArray.sharedInstance().array.removeAll()
        callAPI()
        refreshControl.endRefreshing()
    }
}

extension MainViewController {
    // table view functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PassArray.sharedInstance().array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = PassArray.sharedInstance().array[indexPath.row].timestamp
        cell.detailTextLabel?.text = ("\(PassArray.sharedInstance().array[indexPath.row].duration!) secs")
        
        return cell
    }
}
