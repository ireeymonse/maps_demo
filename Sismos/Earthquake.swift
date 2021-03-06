//
//  Earthquake.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit
import MapKit

class Earthquake: NSObject, MKAnnotation {
   var place: String?
   var magnitude: Double?
   var date: Date
   
   var color: UIColor? {
      guard let mag = magnitude else { return nil }
      return mag < 4 ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : mag < 6 ? #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1) : mag < 7 ? #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1) : #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
   }
   
   init(place: String?, magnitude: Double?, date: Date, lat: Double, lon: Double) {
      self.place = place
      self.magnitude = magnitude
      self.date = date
      self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
   }
   
   // MARK: - MapKit
   
   var coordinate: CLLocationCoordinate2D
   var title: String? { return place }
}


// MARK: - Search

private let kSearchMagnitude = "magnitude?"
private let kSearchFromDate = "from?"
private let kSearchUntilDate = "until?"

struct SearchParams {
   let minMagnitude: Double
   let fromDate, untilDate: Date
   
   static var lastSearch: SearchParams {
      get {
         let minMagnitude = UserDefaults.standard.double(forKey: kSearchMagnitude)
         let from = UserDefaults.standard.double(forKey: kSearchFromDate)
         let until = UserDefaults.standard.double(forKey: kSearchUntilDate)
         
         let fromDate = Date(timeIntervalSinceReferenceDate: from)
         let untilDate = Date(timeIntervalSinceReferenceDate: until)
         
         return SearchParams(minMagnitude: minMagnitude, fromDate: fromDate, untilDate: untilDate)
      }
      set(new) {
         UserDefaults.standard.set(new.minMagnitude, forKey: kSearchMagnitude)
         UserDefaults.standard.set(new.fromDate.timeIntervalSinceReferenceDate, forKey: kSearchFromDate)
         UserDefaults.standard.set(new.untilDate.timeIntervalSinceReferenceDate, forKey: kSearchUntilDate)
      }
   }
}

