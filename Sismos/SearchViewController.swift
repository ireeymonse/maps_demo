//
//  SearchViewController.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit
import SVProgressHUD

let kSearchMagnitude = "magnitude?"
let kSearchFromDate = "from?"
let kSearchUntilDate = "until?"

struct SearchParams {
   let minMagnitude: Double
   let fromDate, untilDate: Date
}

let OneDay: TimeInterval = 24*60*60


class SearchViewController: UIViewController {
   
   @IBOutlet weak var lastSearchButton: UIButton!
   @IBOutlet weak var magnitudeStepper: UIStepper!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var fromDatePicker: UIDatePicker!
   @IBOutlet weak var untilDatePicker: UIDatePicker!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      fromDatePicker.minimumDate = Date()
      untilDatePicker.minimumDate = Date()
      untilDatePicker.date = fromDatePicker.date.addingTimeInterval(OneDay)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      lastSearchButton.isEnabled = (UserDefaults.standard.double(forKey: kSearchMagnitude) != 0)
   }
   
   
   // MARK: - UI events
   
   @IBAction func magnitudeStepperChanged(_ sender: Any) {
      magnitudeLabel.text = "\(magnitudeStepper.value)"
   }
   
   @IBAction func fromDateChanged(_ sender: UIDatePicker) {
      if untilDatePicker.date < sender.date {
         untilDatePicker.date = sender.date
      }
      untilDatePicker.minimumDate = sender.date
   }
   
   @IBAction func lastSearchButtonTapped(_ sender: Any) {
      let minMagnitude = UserDefaults.standard.double(forKey: kSearchMagnitude)
      let from = UserDefaults.standard.double(forKey: kSearchFromDate)
      let until = UserDefaults.standard.double(forKey: kSearchUntilDate)
      
      guard minMagnitude > 0 else {
         // FIXME: handle error?
         return
      }
      let fromDate = Date(timeIntervalSinceReferenceDate: from)
      let untilDate = Date(timeIntervalSinceReferenceDate: until)
      
      search(minMagnitude, fromDate, untilDate)
   }
   
   @IBAction func newSearchButtonTapped(_ sender: Any) {
      search(magnitudeStepper.value, fromDatePicker.date, untilDatePicker.date)
   }
   
   private func search(_ minMagnitude: Double, _ fromDate: Date, _ untilDate: Date) {
      guard Reachability.isConnectedToNetwork() else {
         SVProgressHUD.showError(withStatus: "Conexión no disponible")
         return
      }
      
      let params = SearchParams(minMagnitude: minMagnitude,
                                fromDate: fromDate,
                                untilDate: untilDate)
      performSegue(withIdentifier: "results", sender: params)
      
      // save search
      UserDefaults.standard.set(minMagnitude, forKey: kSearchMagnitude)
      UserDefaults.standard.set(fromDate.timeIntervalSinceReferenceDate, forKey: kSearchFromDate)
      UserDefaults.standard.set(untilDate.timeIntervalSinceReferenceDate, forKey: kSearchUntilDate)
   }
   
   
   // MARK: - Navigation
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)
      
      if let results = segue.destination as? ResultsViewController,
         let params = sender as? SearchParams
      {
         results.searchParams = params
      }
   }
   
}
