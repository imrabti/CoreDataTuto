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
import SwiftRecord
import ImageRow

class EditContactViewController: FormViewController {
    @IBOutlet weak var save: UIBarButtonItem!
    
    var addOrEditContact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if addOrEditContact != nil {
            title = "Edit Contact"
        } else {
            title = "New Contact"
            addOrEditContact = Contact.create() as? Contact
            addOrEditContact?.type = ContactType.Friend.rawValue
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
        if let contact = addOrEditContact {
            let _ = contact.save()
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
            <<< ImageRow() { row in
                row.title = "Contact picture"
                row.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                row.clearAction = .yes(style: UIAlertActionStyle.destructive)
                
                if let picture = self.addOrEditContact?.picture {
                    row.value = UIImage(data: picture)
                }
            }.cellUpdate { cell, row in
                cell.accessoryView?.layer.cornerRadius = 17
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            }.onChange() { row in
                if let picture = row.value {
                    self.addOrEditContact?.picture = UIImagePNGRepresentation(picture)
                }
            }
            
            <<< TextRow(ContactForm.Name.rawValue) { row in
                row.title = "Full Name"
                row.add(rule: RuleRequired())
                
                if let name = addOrEditContact?.name {
                    row.value = name
                }
            }.onChange() { row in
                self.addOrEditContact?.name = row.value
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
            <<< PickerInputRow<String>(ContactForm.ContactType.rawValue) { row in
                row.title = "Contact Type"
                row.options = ContactType.allValues.map {value in value.rawValue}
                row.value = addOrEditContact?.type
            }.onChange() { row in
                self.addOrEditContact?.type = row.value
            }
        
            <<< PhoneRow(ContactForm.PhoneNumber.rawValue) { row in
                row.title = "Phone Number"
                
                if let phoneNumber = addOrEditContact?.phoneNumber {
                    row.value = phoneNumber
                }
            }.onChange() { row in
                self.addOrEditContact?.phoneNumber = row.value
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
            <<< EmailRow(ContactForm.Email.rawValue) { row in
                row.title = "Email"
                row.add(rule: RuleEmail())
                
                if let email = addOrEditContact?.email {
                    row.value = email
                }
            }.onChange() { row in
                self.addOrEditContact?.email = row.value
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
    }
}
