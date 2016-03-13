//
//  AllNewsItemCell.swift
//  ScoopsFy
//
//  Created by Pedro Martin Gomez on 13/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import UIKit

class AllNewsItemCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
