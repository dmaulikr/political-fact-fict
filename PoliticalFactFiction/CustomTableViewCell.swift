//
//  CustomTableViewCell.swift
//  PoliticalFactFiction
//
//  Created by Jason La on 8/24/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var statementLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
