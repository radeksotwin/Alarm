//
//  SectionHeaderCell.swift
//  AlarmTest
//
//  Created by Rdm on 17/05/2022.
//

import UIKit


class SectionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var sectionNameLabel: UILabel!
    static let identifier = "header"
    
    var title: String?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

