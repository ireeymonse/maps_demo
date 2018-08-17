//
//  DetailsViewController.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
   
   @IBOutlet weak var placeContainerView: UIView!
   @IBOutlet weak var placeLabel: UILabel!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
   @IBOutlet weak var mapView: MKMapView!
   
   lazy var formatter: DateFormatter = {
      let f = DateFormatter()
      f.dateFormat = "d/MMM/yy"
      return f
   }()
   
   var earthquake: Earthquake?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      guard let earthquake = earthquake else { return }
      
      let mag = earthquake.magnitude ?? 1
      
      placeLabel.text = earthquake.place
      magnitudeLabel.text = String(format: "%.1f", mag)
      dateLabel.text = formatter.string(from: earthquake.date)
      
      placeContainerView.backgroundColor = earthquake.color
      
      // show point in map
      let region = MKCoordinateRegionMakeWithDistance(earthquake.coordinate, 1000, 1000)
      mapView.setRegion(mapView.regionThatFits(region), animated: false)
      mapView.addAnnotation(earthquake)
   }
   
}
