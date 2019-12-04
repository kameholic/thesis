//
//  TreeTableViewCell.swift
//  thesis
//
//  Created by Mac on 2019. 11. 30..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit

class TreeTableViewCell : UITableViewCell {
    
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var customTitleLabel: UILabel!
    
    override func awakeFromNib() {
        selectedBackgroundView? = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }
    
    var additionButtonActionBlock : ((TreeTableViewCell) -> Void)?;
    
    func setup(withTitle title: String, detailsText: String, level : Int, additionalButtonHidden: Bool) {
        customTitleLabel.text = title
//        print("detailsLabel \(detailsLabel.text!)")
//        detailsLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: 320, height: 9999), limitedToNumberOfLines: 20)
//        detailsLabel.lineBreakMode = .byWordWrapping
//        detailsLabel.numberOfLines = 0
        detailsLabel.text = detailsText
        detailsLabel.numberOfLines = 0
//        self.frame.size.height = detailsLabel.intrinsicContentSize.height;
//        detailsLabel.sizeToFit()
        
        let backgroundColor: UIColor
        if level == 0 {
            backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        } else if level == 1 {
            backgroundColor = UIColor(red: 209.0/255.0, green: 238.0/255.0, blue: 252.0/255.0, alpha: 1.0)
        } else {
            backgroundColor = UIColor(red: 224.0/255.0, green: 248.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        }
        
        self.backgroundColor = backgroundColor
        self.contentView.backgroundColor = backgroundColor
        
        let left = 11.0 + 20.0 * CGFloat(level)
        self.customTitleLabel.frame.origin.x = left
        self.detailsLabel.frame.origin.x = left
    }
    
    func additionButtonTapped(_ sender : AnyObject) -> Void {
        if let action = additionButtonActionBlock {
            action(self)
        }
    }
    
}
