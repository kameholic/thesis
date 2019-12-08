//
//  DetailsViewController.swift
//  thesis
//
//  Created by Mac on 2019. 12. 08..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {
    @IBOutlet weak var detailsLabel: UILabel!

    var detailsText: String = ""

    override func viewDidLoad() {
        if let detailsLabel = detailsLabel {
            detailsLabel.text! = detailsText
        }
    }
}
