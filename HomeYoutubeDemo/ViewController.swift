//
//  ViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 5/14/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    var videos = [Video]()
    var historyVideo = [Video]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestVideo()
        createShadowView()
        UITabBar.appearance().tintColor = UIColor.red
    }
    
    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tableView.rowHeight = 290
        tableView.sectionHeaderHeight = 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        let detailVideo: DetailVideoViewController = storyboard?.instantiateViewController(withIdentifier: "DetailVideoViewController") as! DetailVideoViewController
        detailVideo.detailVideo = video
        detailVideo.requestChannel()
        self.navigationController?.pushViewController(detailVideo, animated: true)
        HistoryManager.savedVideo(video: video)
    }
        
    func createShadowView() {
        headerView.layer.masksToBounds = false
        headerView.layer.shadowColor = UIColor.gray.cgColor
        headerView.layer.shadowOpacity = 0.4
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowRadius = 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func displayDuration(videoDurationAPI: String) -> String {
        var durationVideo = String()
        var videoDuration = [Character]()
        for Character in videoDurationAPI {
            videoDuration.append(Character)
        }
        if  videoDuration.last == "M" {
            durationVideo = videoDurationAPI.replacingOccurrences(of: "H", with: ":").replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "M", with: ":00").replacingOccurrences(of: "S", with: "")
        } else if "M" == videoDuration[videoDuration.count - 3] {
            durationVideo = videoDurationAPI.replacingOccurrences(of: "H", with: ":").replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "M", with: ":0").replacingOccurrences(of: "S", with: "")
        } else {
            durationVideo = videoDurationAPI.replacingOccurrences(of: "H", with: ":").replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        }
        return durationVideo
    }
    
    func reduceTheNumberOf(number: Int) -> String {
        var info = String()
        if number >= 1000 && number < 1000000{
            let result: Int = number / 1000
            info = "\(result)K"
        } else if number >= 1000000 && number < 1000000000{
            let result: Int = number / 1000000
            info = "\(result)M"
        } else if number >= 1000000000 {
            let result: Int = number / 1000000000
            info = "\(result)B"
        } else {
            info = "\(number)"
        }
        return info
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
        let video = videos[indexPath.row]
        let url = URL(string: video.thumbnails)
        let data = try? Data(contentsOf: url!)
        let date = getElapsedInterval(date: convertPublishing(publishedAt: video.publishedAt))
        let viewCount = reduceTheNumberOf(number: video.viewCount)
        
        cell.durationLabel.text = displayDuration(videoDurationAPI: video.duration)
        cell.durationLabel.layer.cornerRadius = 4
        cell.durationLabel.layer.masksToBounds = true
        cell.thumnailsImageView.image = UIImage(data: data!)
        cell.titleLabel.text = video.title
        cell.channelTitleLabel.text = "\(video.channelTitle) \u{2022} \(viewCount) views \u{2022} \(date)"
        return cell
    }
    
    func convertPublishing(publishedAt: String) -> Date {
        let string = publishedAt
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: string)!
        return date
    }
    
    func getElapsedInterval(date: Date) -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: date as Date, to: Date())
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else {
            return "a moment ago"
        }
    }
    
    func requestVideo() {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?part=snippet%20%2C%20contentDetails%2C%20statistics&chart=mostPopular&maxResults=50&key=AIzaSyBYzuJwfh29E1TevQeXXnG7K_ae1EJ5PcE")!
        let task = URLSession.shared.dataTask(with: url) { data, respone, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let items = json["items"] as! [[String: Any]]
            var videos = [Video]()
            for item in items {
                let snippet = item["snippet"] as! [String: Any]
                let statistics = item["statistics"] as! [String: Any]
                let publishedAt = snippet["publishedAt"] as! String
                let viewCount = Int(statistics["viewCount"] as! String)!
                let likeCount = Int(statistics["likeCount"] as! String)!
                let dislikeCount = Int(statistics["dislikeCount"] as! String)!
                let title = snippet["title"] as! String
                let description = snippet["description"] as! String
                let channelId = snippet["channelId"] as! String
                let thumbnails = snippet["thumbnails"] as! [String: Any]
                let medium = thumbnails["medium"] as! [String: Any]
                let thumbnailsUrl = medium["url"] as! String
                let channelTitle = snippet["channelTitle"] as! String
                let contentDetails = item["contentDetails"] as! [String: Any]
                let duration = contentDetails["duration"] as! String
                let id = item["id"] as! String
                let video = Video(title: title, thumbnails: thumbnailsUrl, channelTitle: channelTitle, descriptionVideo: description, channelId: channelId, viewCount: viewCount, duration: duration, publishedAt: publishedAt, likeCount: likeCount, dislikeCount: dislikeCount, id: id)
                    videos.append(video)
            }
            self.videos = videos
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
}


