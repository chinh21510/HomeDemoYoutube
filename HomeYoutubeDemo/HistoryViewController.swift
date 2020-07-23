//
//  HistoryViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/24/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var historyTableView: UITableView!
    var historyVideos = [Video]()
    var viewController = ViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyVideos = HistoryManager.loadedVideo()
        historyTableView.reloadData()
    }
    
    func setupUI() {
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "SuggestVideoCell", bundle: nil), forCellReuseIdentifier: "SuggestVideoCell")
        historyTableView.rowHeight = 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyVideos.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "SuggestVideoCell") as! SuggestVideoCell
        let video = historyVideos[indexPath.row]
        let url = URL(string: video.thumbnails)
        let data = try? Data(contentsOf: url!)
        cell.thumbnailsImage.image = UIImage(data: data!)
        cell.thumbnailsImage.layer.cornerRadius = 8
        cell.thumbnailsImage.contentMode = UIView.ContentMode.scaleAspectFill
        cell.channelTitleLabel.text = video.channelTitle
        cell.titleLabel.text = video.title
        let date = viewController.convertPublishing(publishedAt: video.publishedAt)
        let publishedAt = viewController.getElapsedInterval(date: date)
        let viewCount = viewController.reduceTheNumberOf(number: video.viewCount)
        cell.publishedAtLabel.text = "\(viewCount) views \u{2022} \(publishedAt)"
        return cell
    }

}
