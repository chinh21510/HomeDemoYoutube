//
//  HistoryViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/24/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditVideo {
   
    
    @IBOutlet weak var historyTableView: UITableView!
    
    let realm = try? Realm()
    var namesPlaylist: Results<Playlist>!
    var historyVideos = [Video]()
    var viewController = ViewController()
    var videoChoosed = Video()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        namesPlaylist = realm!.objects(Playlist.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyVideos = HistoryManager.loadedVideo()
        historyTableView.reloadData()
    }
    
    func setupUI() {
        historyTableView.dataSource = self
        historyTableView.delegate = self
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
        cell.delegate = self
        let date = viewController.convertPublishing(publishedAt: video.publishedAt)
        let publishedAt = viewController.getElapsedInterval(date: date)
        let viewCount = viewController.reduceTheNumberOf(number: video.viewCount)
        cell.publishedAtLabel.text = "\(viewCount) views \u{2022} \(publishedAt)"
        return cell
    }

    func displayEditView(_ sender: SuggestVideoCell) {
        let indexPath = self.historyTableView.indexPath(for: sender)
        self.videoChoosed = historyVideos[indexPath!.row]
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let addFavoriteButton: UIAlertAction = UIAlertAction(title: "Add To Favorite", style: .destructive) { (button) in
            for playlist in self.namesPlaylist! {
            if playlist.name == "Favorite Video" {
                try? self.realm!.write {
                    playlist.favoriteVideos.insert(self.videoChoosed, at: 0)
                }
            }
        }
    }
        let addToPlaylistButton: UIAlertAction = UIAlertAction(title: "Add To Playlist", style: .destructive) { (button) in
            let library : LibraryViewController = self.storyboard?.instantiateViewController(identifier: "LibraryViewController") as! LibraryViewController
            library.video = self.videoChoosed
                self.navigationController?.pushViewController(library, animated: true)
        }
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addFavoriteButton)
        alert.addAction(addToPlaylistButton)
        alert.addAction(cancelButton)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        present(alert, animated: true, completion: nil)
    }
    
}
