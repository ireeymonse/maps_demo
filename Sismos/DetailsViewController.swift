//
//  DetailsViewController.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
   
   @IBOutlet weak var placeContainerView: UIView!
   @IBOutlet weak var placeLabel: UILabel!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
   
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
      dateLabel.text = formatter.string(from: earthquake.date!)
      
      placeContainerView.backgroundColor =
         mag < 4 ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : mag < 6 ? #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1) : mag < 7 ? #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1) : #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
   }
   
   // FIXME: map view
   
}
