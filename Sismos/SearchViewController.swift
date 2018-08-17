//
//  SearchViewController.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit
import SVProgressHUD

let OneDay: TimeInterval = 24*60*60

class SearchViewController: UIViewController {
   
   @IBOutlet weak var lastSearchButton: UIButton!
   @IBOutlet weak var magnitudeStepper: UIStepper!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var fromDatePicker: UIDatePicker!
   @IBOutlet weak var untilDatePicker: UIDatePicker!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      fromDatePicker.maximumDate = Date()
      untilDatePicker.minimumDate = fromDatePicker.date
      untilDatePicker.maximumDate = Date()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      lastSearchButton.isEnabled = (SearchParams.lastSearch.minMagnitude > 0)
   }
   
   
   // MARK: - UI events
   
   @IBAction func magnitudeStepperChanged(_ sender: Any) {
      magnitudeLabel.text = String(format: "%.1f", magnitudeStepper.value)
   }
   
   @IBAction func fromDateChanged(_ sender: UIDatePicker) {
      if untilDatePicker.date < sender.date {
         untilDatePicker.date = sender.date
      }
      untilDatePicker.minimumDate = sender.date
   }
   
   @IBAction func lastSearchButtonTapped(_ sender: Any) {
      let params = SearchParams.lastSearch
      guard params.minMagnitude > 0 else {
         // FIXME: handle error?
         return
      }
      search(for: params)
   }
   
   @IBAction func newSearchButtonTapped(_ sender: Any) {
      let params = SearchParams(minMagnitude: magnitudeStepper.value,
                                fromDate: fromDatePicker.date,
                                untilDate: untilDatePicker.date)
      search(for: params)
   }
   
   private func search(for params: SearchParams) {
      guard Reachability.isConnectedToNetwork() else {
         SVProgressHUD.showError(withStatus: "Conexión no disponible")
         return
      }
      performSegue(withIdentifier: "results", sender: params)
      
      // save search
      SearchParams.lastSearch = params
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
