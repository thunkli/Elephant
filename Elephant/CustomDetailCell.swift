//
//  CustomDetailCell.swift
//  Elephant
//
//  Created by admin on 15/11/12.
//  Copyright © 2015年 w3cmm. All rights reserved.
//

import UIKit

class CustomDetailCell: UITableViewCell {
    @IBOutlet weak var detailKey: UILabel!
    @IBOutlet weak var detailValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
