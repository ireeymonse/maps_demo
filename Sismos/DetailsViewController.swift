//
//  DetailsViewController.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD
import AudioToolbox

class DetailsViewController: UIViewController, CLLocationManagerDelegate {
   
   @IBOutlet weak var placeContainerView: UIView!
   @IBOutlet weak var placeLabel: UILabel!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
   @IBOutlet weak var mapView: MKMapView!
   
   var earthquake: Earthquake?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      guard let earthquake = earthquake else { return }
      
      let mag = earthquake.magnitude ?? 1
      
      placeLabel.text = earthquake.place
      magnitudeLabel.text = String(format: "%.1f", mag)
      
      let f = DateFormatter()
      f.dateFormat = "d/MMM/yy"
      dateLabel.text = f.string(from: earthquake.date)
      
      placeContainerView.backgroundColor = earthquake.color
      
      // show point in map
      let region = MKCoordinateRegionMakeWithDistance(earthquake.coordinate, 1000, 1000)
      mapView.setRegion(mapView.regionThatFits(region), animated: false)
      mapView.addAnnotation(earthquake)
      
      enableLocationServices()
   }
   
   
   // MARK: - Location
   
   private let locationManager = CLLocationManager()

   func enableLocationServices() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print(locations)
      
      // check distance
      let there = CLLocation(latitude: earthquake!.coordinate.latitude,
                             longitude: earthquake!.coordinate.longitude)
      if let dist = locations.last?.distance(from: there), dist < 300_000 {
         SVProgressHUD.setHapticsEnabled(true)
         SVProgressHUD.showInfo(withStatus:
            "Sismo ocurrido a \(String(format: "%.1f", dist/1000)) km de tu posición.")
         SVProgressHUD.setHapticsEnabled(false)
         
         // feedback on older devices
         AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
      }
      
      // show user location
      if let here = mapView.annotations.first(where: { $0 is MKUserLocation }) {
         mapView.showAnnotations([here, earthquake!], animated: true)
         manager.stopUpdatingLocation()
      }
   }
   
}
