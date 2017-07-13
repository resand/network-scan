//
//  DeviceCustomTableViewCell.swift
//  RedScan
//
//  Created by René Sandoval on 12/05/17.
//  Copyright © 2017 René Sandoval. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class DeviceCustomTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var makerLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
