//
//  TitleDetailVideoCell.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 5/16/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

protocol YourCellDelegate: class {
    func didPressButton()
}

class TitleDetailVideoCell: UITableViewCell {
    var cellDelegate: YourCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var disLikeCountLabel: UILabel!
    
    @IBAction func addVideoButton() {
        cellDelegate?.didPressButton()
    }
    
}
