//
//  ContactType.swift
//  CoreDataTuto
//
//  Created by Mrabti Idriss on 05.12.17.
//  Copyright © 2017 Mrabti Idriss. All rights reserved.
//

enum ContactType : String {
    static let allValuesSearch = [All, Friend, Work, Family]
    static let allValues = [Friend, Work, Family]
    
    case All
    case Work
    case Friend
    case Family
}
