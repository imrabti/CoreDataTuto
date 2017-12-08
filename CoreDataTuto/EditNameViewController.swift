//
//  EditViewController.swift
//  CoreDataTuto
//
//  Created by Mrabti Idriss on 05.12.17.
//  Copyright © 2017 Mrabti Idriss. All rights reserved.
//

import UIKit
import CoreData
import Eureka
import os.log

class EditNameViewController: FormViewController {
    @IBOutlet weak var save: UIBarButtonItem!
    
    var managedContext: NSManagedObjectContext?
    var entity: NSEntityDescription?
    var addOrEditPerson: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        managedContext = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext!)
        
        if addOrEditPerson != nil {
            title = "Edit Contact"
        } else {
            title = "New Contact"
            addOrEditPerson = NSManagedObject(entity: entity!, insertInto: managedContext) as? Person
            addOrEditPerson?.type = ContactType.Friend.rawValue
        }
        
        setupForm()
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Validate that the user choosed Save
        guard let button = sender as? UIBarButtonItem, button === save else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return false
        }
        
        // Validate the form
        if form.validate().count > 0 {
            os_log("Validation error, some fields are not correct", log: OSLog.default, type: .debug)
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Save or update the contact
        do {
            try self.managedContext?.save()
        } catch _ as NSError {
            os_log("Couldn't save the entity.", log: OSLog.default, type: .debug)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private functions
    
    func setupForm() {
        form
            +++ Section()
            <<< TextRow(ContactForm.Name.rawValue) { row in
                row.title = "Full Name"
                row.add(rule: RuleRequired())
                
                if let name = addOrEditPerson?.name {
                    row.value = name
                }
            }.onChange() { row in
                self.addOrEditPerson?.name = row.value
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
            <<< PickerInputRow<String>(ContactForm.ContactType.rawValue) { row in
                row.title = "Contact Type"
                row.options = ContactType.allValues.map {value in value.rawValue}
                row.value = addOrEditPerson?.type
            }.onChange() { row in
                self.addOrEditPerson?.type = row.value
            }
        
            <<< PhoneRow(ContactForm.PhoneNumber.rawValue) { row in
                row.title = "Phone Number"
                
                if let phoneNumber = addOrEditPerson?.phoneNumber {
                    row.value = phoneNumber
                }
            }.onChange() { row in
                self.addOrEditPerson?.phoneNumber = row.value
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
            <<< EmailRow(ContactForm.Email.rawValue) { row in
                row.title = "Email"
                row.add(rule: RuleEmail())
                
                if let email = addOrEditPerson?.email {
                    row.value = email
                }
            }.onChange() { row in
                self.addOrEditPerson?.email = row.value
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
    }
}
