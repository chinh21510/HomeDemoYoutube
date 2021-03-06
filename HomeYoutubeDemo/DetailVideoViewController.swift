//
//  DetailVideoViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 5/16/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import AVFoundation
class DetailVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, YourCellDelegate {
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var tapPlayerViewButton: UIButton!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var forwardVideoButton: UIButton!
    @IBOutlet weak var backwardVideoButton: UIButton!
    
    var timer = Timer()
    var player: AVPlayer?
    var viewController = ViewController()
    var suggestVideos = [Video]()
    var channel = ChannelVideo(title: String(), thumbnails: String(), subscriberCount: Int())
    var videos = [Video]()
    var detailVideo = Video(title: String(), thumbnails: String(), channelTitle: String(), descriptionVideo: String(), channelId: String(), viewCount: Int(), duration: String(), publishedAt: String(), likeCount: Int(), dislikeCount: Int(), id: String())
    let realm = try? Realm()
    var namesPlaylist: Results<Playlist>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestChannel()
        requestSuggestVideo()
        namesPlaylist = realm!.objects(Playlist.self).sorted(byKeyPath: "name")
        playVideo()
    }
    
    func setupUI() {
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.register(UINib(nibName: "TitleDetailVideoCell", bundle: nil), forCellReuseIdentifier: "TitleDetailVideoCell")
        detailTableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        detailTableView.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        detailTableView.register(UINib(nibName: "SuggestVideoCell", bundle: nil), forCellReuseIdentifier: "SuggestVideoCell")
        self.detailTableView.rowHeight = UITableView.automaticDimension
        remoteVideoView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == detailTableView {
            return suggestVideos.count + 3
        } 
        return Int()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView == detailTableView {
            if indexPath.row == 0 {
                return 150
            } else if indexPath.row == 1 {
                return 80
            } else if indexPath.row >= 3 {
                return 120
            }
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == detailTableView {
            if indexPath.row == 0 {
                let cell = detailTableView.dequeueReusableCell(withIdentifier: "TitleDetailVideoCell") as! TitleDetailVideoCell
                cell.titleLabel.text = detailVideo.title
                cell.cellDelegate = self
                let viewCount = viewController.reduceTheNumberOf(number: detailVideo.viewCount)
                let dislikeCount = viewController.reduceTheNumberOf(number: detailVideo.dislikeCount)
                let likeCount = viewController.reduceTheNumberOf(number: detailVideo.likeCount)
                let date = viewController.convertPublishing(publishedAt: detailVideo.publishedAt)
                let publishedAt = viewController.getElapsedInterval(date: date)
                cell.durationLabel.text = "\(viewCount) view \u{2022} \(publishedAt)"
                cell.disLikeCountLabel.text = "\(dislikeCount)"
                cell.likeCountLabel.text = "\(likeCount)"
                return cell
            } else if indexPath.row == 1 {
                let cell = detailTableView.dequeueReusableCell(withIdentifier: "ChannelCell") as! ChannelCell
                if let url = URL(string: channel.thumbnails), let data = try? Data(contentsOf: url) {
                    cell.channelImageView.layer.cornerRadius = cell.channelImageView.frame.height / 2
                    cell.channelImageView.image = UIImage(data: data)
                }
                cell.channelTitleLabel.text = channel.title
                cell.subscriberCountLabel.text = "\(channel.subscriberCount) subscribers"
                return cell
            } else if indexPath.row == 2 {
                let cell = detailTableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
                cell.descriptionLabel.text = detailVideo.descriptionVideo
                let date = convertPublishing(publishedAt: detailVideo.publishedAt)
                cell.publishedAtLabel.text = "Published At: \(date)"
                return cell
            } else {
                let cell = detailTableView.dequeueReusableCell(withIdentifier: "SuggestVideoCell") as! SuggestVideoCell
                let video = suggestVideos[indexPath.row - 3]
                let url = URL(string: video.thumbnails)
                let data = try? Data(contentsOf: url!)
                cell.thumbnailsImage.image = UIImage(data: data!)
                cell.titleLabel.text = video.title
                cell.channelTitleLabel.text = video.channelTitle
                let date = viewController.convertPublishing(publishedAt: video.publishedAt)
                let publishedAt = viewController.getElapsedInterval(date: date)
                cell.publishedAtLabel.text = "\(video.viewCount) views \u{2022} \(publishedAt)"
                cell.thumbnailsImage.contentMode = UIView.ContentMode.scaleAspectFill
                cell.thumbnailsImage.layer.cornerRadius = 8
                return cell
            }
        }
        return UITableViewCell()
    }
        
    func convertPublishing(publishedAt: String) -> String{
        let string = publishedAt
       let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: string)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = tempLocale
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func requestChannel() {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet%2C%20statistics&id=\(detailVideo.channelId)&maxResults=10&key=AIzaSyDw467uImMBNEdqsUflKGgG7aaRlGgq3zo")!
        let task = URLSession.shared.dataTask(with: url) { data, respone, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let items = json["items"] as! [[String: Any]]
            for item in items {
                let snippet = item["snippet"] as! [String: Any]
                let title = snippet["title"] as! String
                let thumbnails = snippet["thumbnails"] as! [String: Any]
                let medium = thumbnails["medium"] as! [String: Any]
                let url = medium["url"] as! String
                let statistics = item["statistics"] as! [String: Any]
                let subscriberCount = statistics["subscriberCount"] as? Int ?? 0
                let channel = ChannelVideo(title: title, thumbnails: url, subscriberCount: subscriberCount)
                self.channel = channel
            }
            DispatchQueue.main.async {
                self.detailTableView.reloadData()
            }
        }
        task.resume()
    }
    
    func requestSuggestVideo() {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(detailVideo.channelId)&key=AIzaSyDw467uImMBNEdqsUflKGgG7aaRlGgq3zo")!
        let task = URLSession.shared.dataTask(with: url) { data, respone, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let items = json["items"] as! [[String: Any]]
            var videos = [Video]()
            for item in items {
                let id = item["id"] as! [String: Any]
                var videoId = ""
                let snippet = item["snippet"] as! [String: Any]
                let channelId = snippet["channelId"] as! String
                let publishedAt = snippet["publishedAt"] as! String
                let title = snippet["title"] as! String
                let description = snippet["description"] as! String
                let thumbnails = snippet["thumbnails"] as! [String: Any]
                let medium = thumbnails["medium"] as! [String: Any]
                let url = medium["url"] as! String
                let channelTitle = snippet["channelTitle"] as! String
                let kind = id["kind"] as! String
                if kind == "youtube#channel" {
                    videoId = ""
                } else {
                    videoId = id["videoId"] as? String ?? ""
                }
                let video = Video(title: title, thumbnails: url, channelTitle: channelTitle, descriptionVideo: description, channelId: channelId, viewCount: 0, duration: "", publishedAt: publishedAt, likeCount: 0, dislikeCount: 0, id: videoId)
                videos.append(video)
            }
            self.suggestVideos = videos
            DispatchQueue.main.async {
                self.detailTableView.reloadData()
            }
        }
        task.resume()
    }
    
    func didPressButton() {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let addFavoriteButton: UIAlertAction = UIAlertAction(title: "Add To Favorite", style: .destructive) { (button) in
            self.clickLikeButton()
        }
        let addToPlaylistButton: UIAlertAction = UIAlertAction(title: "Add To Playlist", style: .destructive) { (button) in
            let library : LibraryViewController = self.storyboard?.instantiateViewController(identifier: "LibraryViewController") as! LibraryViewController
            library.video = self.detailVideo
            self.navigationController?.pushViewController(library, animated: true)
        }
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addFavoriteButton)
        alert.addAction(addToPlaylistButton)
        alert.addAction(cancelButton)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        present(alert, animated: true, completion: nil)
    }
    
    func clickLikeButton() {
        for playlist in namesPlaylist {
            if playlist.name == "Favorite Video" {
                try? realm!.write {
                    playlist.favoriteVideos.insert(self.detailVideo, at: 0)
                }
            }
        }
    }
    
    func playVideo() {
        YoutubeUrlReciver.h264videosWithYoutubeURL(id: "Kma3NpC3JKQ") { data, error in
            let videoURL = URL(string: data[5])!
            self.player = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.videoView.bounds
            self.videoView.layer.addSublayer(playerLayer)
            self.player!.play()
        }
    }
    
    @objc func displayTap() {
        remoteVideoView.isHidden = true
    }
    
    @IBAction func tapPlayerView(_ sender: Any) {
        remoteVideoView.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(displayTap), userInfo: nil, repeats: false)
    }
   
    
    @IBAction func tapPlayButton(_ sender: Any) {
        player!.pause()
        playVideoButton.isHidden = true
        pauseButton.isHidden = false
    }
   

    @IBAction func tapPauseButton(_ sender: Any) {
        player!.play()
        playVideoButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    
    @IBAction func tapForwardButton(_ sender: Any) {
    }

    @IBAction func tapBackwardButton(_ sender: Any) {
    }
    
}
