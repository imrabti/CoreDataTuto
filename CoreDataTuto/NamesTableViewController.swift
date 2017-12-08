//
//  NamesTableViewController.swift
//  CoreDataTuto
//
//  Created by Mrabti Idriss on 03.12.17.
//  Copyright © 2017 Mrabti Idriss. All rights reserved.
//

import UIKit
import CoreData

class NamesTableViewController: UITableViewController {
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var selectedRowToEdit: IndexPath?
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    var managedContext: NSManagedObjectContext?

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
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            people = (try managedContext?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.people.count
        } else {
            return self.filteredPeople.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableView == self.tableView ? people[indexPath.row].name : filteredPeople[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            do {
                self.managedContext?.delete(self.people[index.row])
                try self.managedContext?.save();
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            
            self.people.remove(at: index.row)
            tableView.reloadData()
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.selectedRowToEdit = index
            self.performSegue(withIdentifier: "EditContact", sender: self.people[index.row])
        }
        
        return [edit, delete]
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let editNameController = navigationController.viewControllers.first as! EditNameViewController

        if segue.identifier == "EditContact" {
            if let selectedContact = sender as? Person {
                editNameController.addOrEditPerson = selectedContact
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToContactContactList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditNameViewController, let contact = sourceViewController.addOrEditPerson {
            if let selectedIndexPath = selectedRowToEdit {
                // Updated model with new contact
                people[selectedIndexPath.row] = contact
                selectedRowToEdit = nil
                
                tableView.reloadData()
            } else {
                // Add a new contact.
                let newIndexPath = IndexPath(row: people.count, section: 0)
                
                people.append(contact)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
}

extension NamesTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // TODO : Filter when contact type changed ...
    }
}

extension NamesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredPeople = self.people.filter { (person: Person) -> Bool in
            if let name = person.name {
                return name.lowercased().contains(self.searchController.searchBar.text!.lowercased())
            }
            return false
        }
        
        self.resultsController.tableView.reloadData()
    }
}
