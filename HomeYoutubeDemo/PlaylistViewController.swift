//
//  PlaylistViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/7/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift
class PlaylistViewController: UIViewController, UITableViewDataSource, EditVideo {
   
    
    
    
    @IBOutlet weak var namePlaylistView: UIView!
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var videosCountLabel: UILabel!
    @IBOutlet weak var EditVideoView: UIView!
    @IBOutlet weak var removeVideoButton: UIButton!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    @IBOutlet weak var cancelEditVideoButton: UIButton!
    
    let realm = try? Realm()
    var namesPlaylist: Results<Playlist>!
    var videos = [Video]()
    var namePlaylist = String()
    var viewController = ViewController()
    var videoChoose = Video()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        playlistTableView.dataSource = self
        playlistTableView.register(UINib(nibName: "SuggestVideoCell", bundle: nil), forCellReuseIdentifier: "SuggestVideoCell")
        playlistTableView.rowHeight = 120
        playlistLabel.text = namePlaylist
        if videos.count == 0 {
            playlistImage.image = UIImage(named: "plus1")
        } else {
            let url = URL(string: videos[0].thumbnails)!
            let data = try? Data(contentsOf: url)
            playlistImage.image = UIImage(data: data!)
        }
        playlistImage.contentMode = .scaleAspectFill
        playlistImage.layer.cornerRadius = 10
        videosCountLabel.text = "\(videos.count) Videos"
        EditVideoView.layer.cornerRadius = 12
        cancelEditVideoButton.layer.cornerRadius = 12
        removeVideoButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        removeVideoButton.layer.cornerRadius = 12
        addToFavoriteButton.layer.cornerRadius = 12
        addToFavoriteButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.addToFavoriteButton.frame.size.width, height: 1)
        topBorder.backgroundColor = UIColor.systemGray5.cgColor
        addToFavoriteButton.layer.addSublayer(topBorder)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTableView.dequeueReusableCell(withIdentifier: "SuggestVideoCell") as! SuggestVideoCell
        let video = videos[indexPath.row]
        let url = URL(string: video.thumbnails)
        let data = try? Data(contentsOf: url!)
        cell.thumbnailsImage.image = UIImage(data: data!)
        cell.thumbnailsImage.contentMode = UIView.ContentMode.scaleAspectFill
        cell.thumbnailsImage.layer.cornerRadius = 8
        cell.channelTitleLabel.text = video.channelTitle
        cell.titleLabel.text = video.title
        cell.delegate = self
        self.videoChoose = video
        let date = viewController.convertPublishing(publishedAt: video.publishedAt)
        let publishedAt = viewController.getElapsedInterval(date: date)
        let viewCount = viewController.reduceTheNumberOf(number: video.viewCount)
        cell.publishedAtLabel.text = "\(viewCount) views \u{2022} \(publishedAt)"
        return cell
    }
    
    func displayEditView(_ sender: SuggestVideoCell) {
        EditVideoView.isHidden = false
        namePlaylistView.alpha = 0.3
        playlistTableView.alpha = 0.3
    }
    
    
    @IBAction func removeVideo(_ sender: Any) {
        try! realm!.write {
            realm!.delete(videoChoose)
        }
        playlistTableView.reloadData()
    }
    
    
    
    @IBAction func addToFavorite(_ sender: Any) {
    }
    
    
    
    @IBAction func cancelEditVideo(_ sender: Any) {
        EditVideoView.isHidden = true
        namePlaylistView.alpha = 1
        playlistTableView.alpha = 1
    }
    
}
