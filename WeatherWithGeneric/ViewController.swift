//
//  ViewController.swift
//  WeatherWithGeneric
//
//  Created by Justinus Andjarwirawan on 10/5/15.
//  Copyright © 2015 Petra Christian University. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var myLabel: UILabel!
    let locationManager = CLLocationManager()
    var lat: Double?
    var long: Double?
    var count: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization() //only active when app in use
        self.locationManager.startUpdatingLocation()
        self.mapView.hidden = true
        self.mapView.showsUserLocation = false
        lat = self.mapView.userLocation.coordinate.latitude
        long = self.mapView.userLocation.coordinate.longitude
    }

    func alertMe(temp: Double) {
        let alertKu = UIAlertController(title: "Location Found", message: "temp: \(temp)°C", preferredStyle: UIAlertControllerStyle.Alert)
        alertKu.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertKu, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //print("center: \(center)")
        //Surabaya lat lang
        //lat = -7.2653
        //long = 112.7425
        lat = center.latitude
        long = center.longitude
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://api.forecast.io/forecast/09c863b692bb3e7e1bcadcb05dc0d4ca/\(lat!),\(long!)?units=si")!
        let dataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                //print(jsonData)
                let results = jsonData.objectForKey("currently") as! NSDictionary

                for (key, value) in results {
                    //print(key, value)
                    switch key as! NSObject {
                    case "temperature":
                dispatch_async(dispatch_get_main_queue(), {
                    print("\(self.count)temperature: \(value)")
                    self.count! += 1
                    //self.alertMe(value as! Double)
                        self.myLabel.text = "\(String(value as! Double))"
                }) //end of dispatch
                    case "humidity":
                        print("\(self.count)humidity: \((value as! Double)*100)%")
                        self.count! += 1
                    default: print("", terminator: "")
                    }
                } //end of for (key, value)

            } catch {
                print("error: \(error)")
            }
        }
        dataTask.resume()
        
        //zoom level: 1
/*        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
*/
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error: " + error.localizedDescription)
    }

}

