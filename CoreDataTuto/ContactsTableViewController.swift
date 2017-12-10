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
    var contacts: [[Contact]] = []
    var contactSections: [String] = []
    
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
        
        if (contacts.isEmpty) {            
            // load all contacts from database
            let allContacts = Contact.all() as! [Contact]
            
            // Group contacts by section
            for contactType in ContactType.allValues {
                let dataForSection = allContacts.filter({ $0.type == contactType.rawValue })
                
                if dataForSection.count > 0 {
                    contacts.append(dataForSection)
                    contactSections.append(contactType.rawValue)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return contactSections.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return contacts[section].count
        } else {
            return self.filteredContacts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView == self.tableView) {
            return contactSections[section]
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ContactTableViewCell else {
            fatalError("The dequeued cell is not an instance of ContactTableViewCell.")
        }
        
        cell.fullName.text = tableView == self.tableView ? contacts[indexPath.section][indexPath.row].name : filteredContacts[indexPath.row].name
        cell.email.text = tableView == self.tableView ? contacts[indexPath.section][indexPath.row].email : filteredContacts[indexPath.row].email
        cell.phoneNumber.text = tableView == self.tableView ? contacts[indexPath.section][indexPath.row].phoneNumber : filteredContacts[indexPath.row].phoneNumber
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            // Remove contact from the model
            self.contacts[indexPath.section][indexPath.row].delete()
            self.contacts[indexPath.section].remove(at: index.row)

            // Remove the contact from the TableView
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if self.contacts[indexPath.section].isEmpty {
                self.contacts.remove(at: indexPath.section)
                self.contactSections.remove(at: indexPath.section)
                
                // Remove the section from the TableView
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            
            Contact.save()
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.selectedRowToEdit = index
            self.performSegue(withIdentifier: "EditContact", sender: self.contacts[index.section][index.row])
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
                if (contactSections[selectedIndexPath.section] != contact.type) {
                    if let section = contactSections.index(where: { $0 == contact.type }) {
                        contacts[selectedIndexPath.section].remove(at: selectedIndexPath.row)
                        contacts[section].append(contact)
                        
                        // Update TableView
                        tableView.moveRow(at: selectedIndexPath, to: IndexPath(row: contacts[section].count - 1, section: section))
                    } else {
                        contacts[selectedIndexPath.section].remove(at: selectedIndexPath.row)
                        contactSections.append(contact.type!)
                        contacts.append([contact])
                        
                        // Update the TableView
                        tableView.reloadData()
                    }
                }
                
                if contacts[selectedIndexPath.section].isEmpty {
                    contacts.remove(at: selectedIndexPath.section)
                    contactSections.remove(at: selectedIndexPath.section)
                    
                    // Update TableView
                    tableView.deleteSections(IndexSet(integer: selectedIndexPath.section), with: .automatic)
                }
                
                selectedRowToEdit = nil
            } else {
                if let section = contactSections.index(where: { $0 == contact.type }) {
                    contacts[section].append(contact)
                    tableView.insertRows(at: [IndexPath(row: contacts[section].count - 1, section: section)], with: .automatic)
                } else {
                    // Add new Section and insert the row
                    let newSectionIndex = contactSections.count
                    contactSections.append(contact.type!)
                    contacts.append([contact])
                    
                    // Update the TableView
                    tableView.insertSections(IndexSet(integer: newSectionIndex), with: .automatic)
                }
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
        /*self.filteredContacts = self.contacts.filter { (contact: Contact) -> Bool in
            if let name = contact.name {
                return name.lowercased().contains(self.searchController.searchBar.text!.lowercased())
            }
            return false
        }*/
        
        self.resultsController.tableView.reloadData()
    }
}
