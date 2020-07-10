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
    
    @IBOutlet weak var playlistView: UIView!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var videoView: UIView!
    
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
        playlistTableView.register(UINib(nibName: "SuggestionCell", bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
        self.detailTableView.rowHeight = UITableView.automaticDimension
        playlistView.layer.cornerRadius = 10
        playlistTableView.layer.cornerRadius = 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == detailTableView {
            return suggestVideos.count + 3
        } else if tableView == playlistTableView {
            return namesPlaylist?.count ?? 1
        }
        return Int()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView == detailTableView {
            if indexPath.row == 0 {
                return 150
            } else if indexPath.row == 1 {
                return 80
            } else if indexPath.row == 2 {
                return UITableView.automaticDimension
            } else if indexPath.row >= 3 {
                return 130
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
                cell.descriptionLabel.text = detailVideo.description
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
                return cell
            }
        } else if tableView == playlistTableView {
            let cell = playlistTableView.dequeueReusableCell(withIdentifier: "SuggestionCell") as! SuggestionCell
            cell.suggestionLabel.text = namesPlaylist?[indexPath.row].name ?? ""
            return cell
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
        let url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet%2C%20statistics&id=\(detailVideo.channelId)&maxResults=10&key=AIzaSyAIK9Vo9KNPUHnRyFq-2QeNv2dt6nG-Pkw")!
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
        let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(detailVideo.channelId)&key=AIzaSyAIK9Vo9KNPUHnRyFq-2QeNv2dt6nG-Pkw")!
        let task = URLSession.shared.dataTask(with: url) { data, respone, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let items = json["items"] as! [[String: Any]]
            var videos = [Video]()
            for item in items {
                let id = item["id"] as! [String: Any]
                let videoId = id["videoId"] as! String
                let snippet = item["snippet"] as! [String: Any]
                let channelId = snippet["channelId"] as! String
                let publishedAt = snippet["publishedAt"] as! String
                let title = snippet["title"] as! String
                let description = snippet["description"] as! String
                let thumbnails = snippet["thumbnails"] as! [String: Any]
                let medium = thumbnails["medium"] as! [String: Any]
                let url = medium["url"] as! String
                let channelTitle = snippet["channelTitle"] as! String
                
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
        playlistView.isHidden = false
        videoView.alpha = 0.3
        detailTableView.alpha = 0.3
    }
    
    func clickLikeButton() {
        for playlist in namesPlaylist {
            if playlist.name == "Loda" {
                try? realm!.write {
                    playlist.favoriteVideos.append(detailVideo)
                }
            }
        }
    }
    
    @IBAction func turnOffPlaylistTableView(_ sender: Any) {
        playlistView.isHidden = true
        videoView.alpha = 1
        detailTableView.alpha = 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == playlistTableView {
            let playlist = namesPlaylist[indexPath.row]
            try? realm!.write {
                playlist.favoriteVideos.append(detailVideo)
            }
            playlistView.isHidden = true
            print(playlist.favoriteVideos)
        }
    }
    
    func playVideo() {
        YoutubeUrlReciver.h264videosWithYoutubeURL(id: "Kma3NpC3JKQ") { data, error in
            let videoURL = URL(string: data[5])!
            let player = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.videoView.bounds
            self.videoView.layer.addSublayer(playerLayer)
            player.play()
        }
    }
}
