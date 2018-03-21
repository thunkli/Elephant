//
//  CustomCell.swift
//  Elephant
//
//  Created by 李金标 on 15/11/3.
//  Copyright © 2015年 w3cmm. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var movieHead: UIImageView!
    @IBOutlet weak var movieScore: UILabel!
    @IBOutlet weak var movieCasts: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
