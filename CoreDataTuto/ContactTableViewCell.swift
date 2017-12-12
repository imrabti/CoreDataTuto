//
//  ContactTableViewCell.swift
//  CoreDataTuto
//
//  Created by imrabti on 09.12.17.
//  Copyright © 2017 Mrabti Idriss. All rights reserved.
//

import UIKit
import Toucan

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func contactAvatar(_ picture: UIImage) {
        let resizedImage = Toucan(image: picture).resize(CGSize(width: 68, height: 68), fitMode: Toucan.Resize.FitMode.crop).image
        self.picture.image = Toucan(image: resizedImage!).maskWithEllipse().image
    }
}
