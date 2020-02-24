//
//  HistoryViewController.swift
//  WeatherApp
//
//  Created by Chaithra T V on 20/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var presenter: HistoryViewToPresenterProtocol?
    var locationviewController: WeatherInfoViewController?
    
    var realm: Realm!
    var list: Results<History> {
        get{
            return realm.objects(History.self)
        }
    }
    
    @IBAction func clearButtonAction(_ sender: Any) {
        try! realm.write({
            realm.deleteAll()
            tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.tableView.tableFooterView = UIView()
    }
    
    
}

extension HistoryViewController: HistoryPresenterToViewProtocol {
    
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        cell.titleLabel.text = self.list[indexPath.row].placeName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHistory = self.list[indexPath.row]
        locationviewController?.selectedLocationHistory(selectedHistory)
        self.navigationController?.popViewController(animated: true)
    }
}
