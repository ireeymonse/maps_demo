//
//  ResultsViewController.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ResultsViewController: UIViewController {
   
   @IBOutlet weak var datesLabel: UILabel!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var tableView: UITableView!

   var refreshControl = UIRefreshControl()
   
   var searchParams: SearchParams?
   internal var results = [Earthquake]()
   lazy var formatter: DateFormatter = {
      let f = DateFormatter()
      f.dateFormat = "d/MMM/yy"
      return f
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      guard let params = searchParams else { return }
      
      // ui config
      datesLabel.text = "Del \(formatter.string(from: params.fromDate)) al \(formatter.string(from: params.untilDate))"
      
      magnitudeLabel.text = String(format: "Magnitud ≥ %.1f", params.minMagnitude)
      
      refreshControl.endRefreshing()
      refreshControl.tintColor = #colorLiteral(red: 0.9494900174, green: 0.4276204102, blue: 0, alpha: 1)
      refreshControl.addTarget(self, action: #selector(refreshResults(_:)), for: .valueChanged)
      tableView.refreshControl = refreshControl
      
      // initial load
      SVProgressHUD.show(withStatus: "Cargando")
      loadResults { [weak self] (error, results) in
         guard error == nil, let results = results else { return }

         self?.results = results
         self?.tableView.reloadData()

         SVProgressHUD.dismiss()
      }
   }
   
   
   // MARK: - Data
   
   @objc func refreshResults(_ sender: AnyObject) {
      loadResults { [weak self] (error, results) in
         guard error == nil, let results = results else { return }
         
         self?.results = results
         self?.tableView.reloadData()
         
         self?.refreshControl.endRefreshing()
      }
   }
   
   private func loadResults(_ completion: @escaping (NSError?, [Earthquake]?) -> ()) {
      
      guard let params = searchParams else {
         completion(nil, nil)
         return
      }
      // look for repeated dates
      let dayFrom = Int(params.fromDate.timeIntervalSinceReferenceDate / OneDay)
      let dayUntil = Int(params.untilDate.timeIntervalSinceReferenceDate / OneDay)
      let offset = (dayFrom == dayUntil ? OneDay: 0)
      
      let f = DateFormatter()
      f.dateFormat = "yyyy-MM-dd"
      
      let from = f.string(from: params.fromDate)
      let until = f.string(from: params.untilDate + offset)
      
      let url = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=\(from)&endtime=\(until)&minmagnitude=\(params.minMagnitude)"
      
      Alamofire.request(url, method: .get, parameters: [:], encoding: JSONEncoding.default)
         .responseJSON { response in
            switch response.result {
               
            case .failure(let error):
               SVProgressHUD.showError(withStatus: error.localizedDescription)
               completion(error as NSError, nil)
               
            case .success:
               let json = response.result.value as? [String: Any]
               
               guard let metadata = json?["metadata"] as? [String: Any],
                  Int("\(metadata["status"] ?? "0")") == 200,
                  let body = json?["features"] as? NSArray else
               {
                  // construct error
                  let e = NSError(domain: "iree", code: Int("\(json?["metadata.status"] ?? "")") ?? 500, userInfo: [ NSLocalizedDescriptionKey :  "Error en el servidor" ])
                  completion(e, nil)
                  return
               }
               
               // get result
               let result: [Earthquake] = body.compactMap {
                  
                  // properties
                  guard let info = $0 as? [String : AnyObject],
                     let properties = info["properties"] as? [String: Any],
                     let t = properties["time"] as? Double else
                     {
                        return nil
                  }
                  
                  // vaidate geometry
                  guard let geo = info["geometry"] as? [String: Any],
                     geo["type"] as? String == "Point",
                     let coordinates = geo["coordinates"] as? [Double] else
                  {
                     return nil
                  }
                  
                  return Earthquake(place: properties["place"] as? String,
                                    magnitude: properties["mag"] as? Double,
                                    date: Date(timeIntervalSince1970: t / 1000),
                                    lat: coordinates[1], lon: coordinates[0])
               }
               completion(nil, result)
            }
      }
   }
   
   
   // MARK: - Navigation
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)
      
      if let details = segue.destination as? DetailsViewController,
         let cell = sender as? UITableViewCell,
         let indexPath = tableView.indexPath(for: cell)
      {
         details.earthquake = results[indexPath.row]
      }
   }
   
}


// MARK: -

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return results.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultCell
     
      let earthquake = results[indexPath.row]
      let mag = earthquake.magnitude ?? 1
      
      cell.placeLabel.text = earthquake.place
      cell.magnitudeLabel.text = String(format: "%.1f", mag)
      cell.dateLabel.text = formatter.string(from: earthquake.date)
      
      cell.placeContainerView.backgroundColor = earthquake.color
      
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
   }
}

class ResultCell: UITableViewCell {
   
   @IBOutlet weak var placeContainerView: UIView!
   @IBOutlet weak var placeLabel: UILabel!
   @IBOutlet weak var magnitudeLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      let orig = placeContainerView.backgroundColor
      super.setSelected(selected, animated: animated)
      placeContainerView.backgroundColor = orig
   }
}


