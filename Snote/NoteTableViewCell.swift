//
//  NoteTableViewCell.swift
//  Snote
//
//  Created by Andrey Kolpakov on 05.12.2017.
//  Copyright © 2017 Andrey Kolpakov. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var nameCell: UILabel!
    @IBOutlet weak var textCell: UILabel!
    @IBOutlet weak var dateCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
