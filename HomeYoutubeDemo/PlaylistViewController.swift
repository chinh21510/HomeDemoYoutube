//
//  PlaylistViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/7/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var namePlaylistView: UIView!
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var playlistTableView: UITableView!
    var videos = [Video]()
    var namePlaylist = String()
    var viewController = ViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    func setupUI() {
        playlistTableView.dataSource = self
        playlistTableView.register(UINib(nibName: "SuggestVideoCell", bundle: nil), forCellReuseIdentifier: "SuggestVideoCell")
        playlistTableView.rowHeight = 130
        playlistLabel.text = namePlaylist
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
        cell.channelTitleLabel.text = video.channelTitle
        cell.titleLabel.text = video.title
        let date = viewController.convertPublishing(publishedAt: video.publishedAt)
        let publishedAt = viewController.getElapsedInterval(date: date)
        let viewCount = viewController.reduceTheNumberOf(number: video.viewCount)
        cell.publishedAtLabel.text = "\(viewCount) views \u{2022} \(publishedAt)"
        return cell
    }
}
