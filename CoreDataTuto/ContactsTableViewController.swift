//
//  NamesTableViewController.swift
//  CoreDataTuto
//
//  Created by Mrabti Idriss on 03.12.17.
//  Copyright © 2017 Mrabti Idriss. All rights reserved.
//

import UIKit
import CoreData
import SwiftRecord

class ContactsTableViewController: UITableViewController {
    var contacts: [Contact] = []
    var filteredContacts: [Contact] = []
    var selectedRowToEdit: IndexPath?
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsController.tableView.dataSource = self
        self.resultsController.tableView.delegate = self
        self.resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = ContactType.allValues.map({t in t.rawValue})
        self.searchController.searchBar.placeholder = "Search Contacts"
        
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contacts = Contact.all() as! [Contact]
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.contacts.count
        } else {
            return self.filteredContacts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableView == self.tableView ? contacts[indexPath.row].name : filteredContacts[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.contacts[index.row].delete()
            self.contacts.remove(at: index.row)
            
            tableView.reloadData()
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.selectedRowToEdit = index
            self.performSegue(withIdentifier: "EditContact", sender: self.contacts[index.row])
        }
        
        return [edit, delete]
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let editNameController = navigationController.viewControllers.first as! EditContactViewController

        if segue.identifier == "EditContact" {
            if let selectedContact = sender as? Contact {
                editNameController.addOrEditContact = selectedContact
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToContactContactList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditContactViewController, let contact = sourceViewController.addOrEditContact {
            if let selectedIndexPath = selectedRowToEdit {
                // Updated model with new contact
                contacts[selectedIndexPath.row] = contact
                selectedRowToEdit = nil
                
                tableView.reloadData()
            } else {
                // Add a new contact.
                let newIndexPath = IndexPath(row: contacts.count, section: 0)
                
                contacts.append(contact)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
}

extension ContactsTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // TODO : Filter when contact type changed ...
    }
}

extension ContactsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredContacts = self.contacts.filter { (contact: Contact) -> Bool in
            if let name = contact.name {
                return name.lowercased().contains(self.searchController.searchBar.text!.lowercased())
            }
            return false
        }
        
        self.resultsController.tableView.reloadData()
    }
}
