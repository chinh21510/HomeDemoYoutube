//
//  DetailVideoViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 5/16/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

class DetailVideoViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var videoImage: UIView!
    @IBOutlet weak var detailTableView: UITableView!
    
    var channel = Channel(channelId: String(), channelTitle: String(), subscriberCount: String(), thumbnails: String())
    var videos = [Video]()
    var titleVideo: String = ""
    var duration: String = ""
    var likeCount = String()
    var dislikeCount = String()
    var viewCount = String()
    var channelId = String()
    var descriptionVideo = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestChannel()
    }
    
     func convertPublishing(publishedAt: String) -> Date {
        let string = publishedAt
        let dateFormatter = DateFormatter()
    //       let tempLocale = dateFormatter.locale
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
    
    func setupUI() {
        detailTableView.dataSource = self
        detailTableView.register(UINib(nibName: "TitleDetailVideoCell", bundle: nil), forCellReuseIdentifier: "TitleDetailVideoCell")
        detailTableView.rowHeight = 150
        detailTableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = detailTableView.dequeueReusableCell(withIdentifier: "TitleDetailVideoCell") as! TitleDetailVideoCell
//            cell.titleLabel.text = titleVideo
//            cell.durationLabel.text = "\(viewCount) view \u{2022} \(duration)"
//            cell.disLikeCountLabel.text = "\(dislikeCount)"
//            cell.likeCountLabel.text = "\(likeCount)"
//            return cell
//        } else if indexPath.row == 1 {
            let cell = detailTableView.dequeueReusableCell(withIdentifier: "ChannelCell") as! ChannelCell
            let url = URL(string: channel.thumbnails)
            print(channel.thumbnails)
            let data = try? Data(contentsOf: url!)
            cell.channelImageView.image = UIImage(data: data!)
            cell.channelTitleLabel.text = channel.channelTitle
            cell.subscriberCountLabel.text = "\(channel.channelTitle) subscribers"
            return cell
//        } else if indexPath.row == 2 {
//            let cell = detailTableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
//            cell.descriptionLabel.text = descriptionVideo
//            let publishedAt = getElapsedInterval(date: convertPublishing(publishedAt: channel.publishedAt))
//            cell.publishedAtLabel.text =
//            return cell
//        }
    }
    
    func requestChannel() {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet%2C%20statistics&id=\(channelId)&maxResults=10&key=AIzaSyB_qQb1qd1wrTT-aAJptpyP_5Dzk547x-8")!
        let task = URLSession.shared.dataTask(with: url) { data, respone, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let items = json["items"] as! [[String: Any]]
            for item in items {
                let snippet = item["snippet"] as! [String: Any]
                let title = snippet["title"] as! String
                let thumbnails = snippet["thumbnails"] as! [String: Any]
                let medium = thumbnails["medium"] as! [String: Any]
                let url = medium["url"] as! String
                print(url)
                print("a")
                let statistics = item["statistics"] as! [String: Any]
                let subscriberCount = statistics["subscriberCount"] as! String
                let channel = Channel(channelId: self.channelId, channelTitle: title, subscriberCount: subscriberCount, thumbnails: url)
                self.channel = channel
            }
            DispatchQueue.main.async {
                self.detailTableView.reloadData()
            }
        }
        task.resume()
    }
}
