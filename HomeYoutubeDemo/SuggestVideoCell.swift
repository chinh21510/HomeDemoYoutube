//
//  SuggestVideoCell.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/23/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

protocol EditVideo: class {
    func displayEditView(_ sender: SuggestVideoCell)
}

class SuggestVideoCell: UITableViewCell {
    weak var delegate: EditVideo?
    
    @IBOutlet weak var thumbnailsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!
    @IBOutlet weak var editVideoButton: UIButton!
    
    @IBAction func editVideoDidTap(_ sender: Any) {
        delegate?.displayEditView(self)
    }
    
    
}
