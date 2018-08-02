//
//  CourseTableViewCell.swift
//  Homework
//
//  Created by Ezra Celli on 5/16/18.
//  Copyright © 2018 Ezra Celli. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    
// MARK: Properties
    @IBOutlet weak var courseName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
