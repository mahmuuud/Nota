
//
//  NoteTableViewCell.swift
//  Nota
//
//  Created by mahmoud mohamed on 7/12/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit

protocol NoteCellProtocol {
    func configureCell(title:String)
}

class NoteTableViewCell: UITableViewCell,NoteCellProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet weak var noteTiltleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(title: String) {
        self.noteTiltleLabel.text = title
    }
    
}
