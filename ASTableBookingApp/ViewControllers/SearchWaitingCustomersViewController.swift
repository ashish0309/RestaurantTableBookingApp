//
//  SearchWaitingCustomersViewController.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/2/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit

class SearchWaitingCustomersViewController: UITableViewController, UISearchBarDelegate {
    var searchBar: UISearchBar!
    var searchedCustomers = [WaitingCustomers]()
    let defaultCellIdentifier = "defaultSearchCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 50, height: 40))
        let sView = UIView()
        sView.frame = searchBar.bounds
        sView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.placeholder = "Type Name or Phone No"
        searchBar.becomeFirstResponder()
        navigationItem.titleView = sView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !searchBar.isFirstResponder else {
            return searchedCustomers.count
        }
        guard let searchText = searchBar.text  else {
            return searchedCustomers.count
        }
        return searchedCustomers.count == 0 && searchText.count > 0 ? 1 : searchedCustomers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: defaultCellIdentifier)
        }
        if searchedCustomers.count == 0 {
            cell.textLabel?.text = "Searched returned 0 results"
            cell.detailTextLabel?.text =  nil
            return cell!
        }
        let waitingCustomer = searchedCustomers[indexPath.row]
        cell.textLabel?.attributedText = Utilities.getStyledStringFor(name: waitingCustomer.customerName,
                                                                      phoneNumber: waitingCustomer.phoneNumber)
        if var index = waitingCustomer.waitingIndex {
            index += 1
            cell.detailTextLabel?.text =  index.ordinal
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchedCustomers.count > 0 {
            searchedCustomers = []
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchedText = searchBar.text?.lowercased() {
            searchedCustomers = ASFirebaseDataSource.database.getSearchedCustomers(searchedtext: searchedText)
            searchBar.resignFirstResponder()
            tableView.reloadData()
        }
    }
    
    deinit {
        
    }
    
}

