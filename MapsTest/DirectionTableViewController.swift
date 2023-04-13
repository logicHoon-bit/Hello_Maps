//
//  DirectionTableViewController.swift
//  MapsTest
//
//  Created by 이치훈 on 2023/04/13.
//

import Foundation
import UIKit

class DirectionTableViewController: UITableViewController {
    
    var directions = [String]() {
        didSet{
            tableView.reloadData()
            print(directions)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(DirectionTableViewCell.self, forCellReuseIdentifier: "DirectionTableViewCell")
    }
    
}

extension DirectionTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionTableViewCell", for: indexPath) as? DirectionTableViewCell {
            cell.directionLabel.text = self.directions[indexPath.row]
            return cell
        }else{
            let cell = DirectionTableViewCell(style: .default, reuseIdentifier: "DirectionTableViewCell")
            return cell
        }
    }
    
    
    
}
