//
//  HistoryTableViewCell.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/24.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit

protocol tapManager: AnyObject {
    func tapOnPreview(_ preview: Bool, cell: HistoryTableViewCell)
}


class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var preViewButton: UIButton!
    @IBOutlet weak var rePrintButton: UIButton!
    @IBOutlet weak var backView: UIView!
    
    weak var delegate: tapManager?

    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 10
        backView.layer.borderWidth = 1.0
        backView.layer.borderColor = UIColor.black.cgColor
        rePrintButton.layer.borderWidth = 1.0
        rePrintButton.layer.cornerRadius = 5
        rePrintButton.layer.borderColor = UIColor.systemBlue.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapPreView(_ sender: Any) {
        self.delegate?.tapOnPreview(true, cell: self)
    }
    
    @IBAction func tapPrint(_ sender: Any) {
        self.delegate?.tapOnPreview(false, cell: self)
    }
}
