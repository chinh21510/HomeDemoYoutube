//
//  SearchViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/23/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift
class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var suggestionTableView: UITableView!
    @IBOutlet weak var resultVideoTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let viewController = ViewController()
    var searchBarText = String()
    var suggestions = [String]()
    var searchResult = [Video]()
    var historyVideo = [Video]()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        suggestionTableView.register(UINib(nibName: "SuggestionCell", bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        suggestionTableView.dataSource = self
        suggestionTableView.delegate = self
        resultVideoTableView.register(UINib(nibName: "SuggestVideoCell", bundle: nil), forCellReuseIdentifier: "SuggestVideoCell")
        resultVideoTableView.dataSource = self
        resultVideoTableView.delegate = self
        resultVideoTableView.isHidden = true
        resultVideoTableView.rowHeight = 130
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
        } else {
            searchBarText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            requestSuggestion()
            suggestionTableView.isHidden = false
            resultVideoTableView.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarText = searchBar.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        requestSearchResult()
        suggestionTableView.isHidden = true
        resultVideoTableView.isHidden = false
    }
    
    func requestSuggestion() {
        let url = URL(string: "http://google.com/complete/search?output=firefox&q=\(searchBarText)")!
        let task = URLSession.shared.dataTask(with: url) { data, respone, error in
            let string = String(data: data!, encoding: .isoLatin2)
            let json = try? JSONSerialization.jsonObject(with: string!.data(using: .utf8)!, options: .mutableContainers) as? [Any]
            let suggestions = json![1] as! [String]
            self.suggestions = suggestions
            DispatchQueue.main.async {
                self.suggestionTableView.reloadData()
            }
        }
        task.resume()
    }
    
    func requestSearchResult() {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&q=\(searchBarText)&key=AIzaSyCXJyeHSQMYGodZlJjcfIrCMjVQGmQlOxM")
        let task = URLSession.shared.dataTask(with: url!) { data, respone, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let items = json["items"] as! [[String: Any]]
            var videos = [Video]()
            for item in items {
                let snippet = item["snippet"] as! [String: Any]
                let channelId = snippet["channelId"] as! String
                let publishedAt = snippet["publishedAt"] as! String
                let title = snippet["title"] as! String
                let description = snippet["description"] as! String
                let thumbnails = snippet["thumbnails"] as! [String: Any]
                let medium = thumbnails["medium"] as! [String: Any]
                let url = medium["url"] as! String
                let channelTitle = snippet["channelTitle"] as! String
                let video = Video(title: title, thumbnails: url, channelTitle: channelTitle, descriptionVideo: description, channelId: channelId, viewCount: 0, duration: "", publishedAt: publishedAt, likeCount: 0, dislikeCount: 0)
                videos.append(video)
            }
            self.searchResult = videos
            DispatchQueue.main.async {
                self.resultVideoTableView.reloadData()
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == suggestionTableView {
             return suggestions.count
        } else if tableView == resultVideoTableView {
            return searchResult.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == suggestionTableView {
            let cell = suggestionTableView.dequeueReusableCell(withIdentifier: "SuggestionCell") as! SuggestionCell
            let suggestion = suggestions[indexPath.row]
            cell.suggestionLabel.text = suggestion
            return cell
        } else if tableView == resultVideoTableView {
            let cell = resultVideoTableView.dequeueReusableCell(withIdentifier: "SuggestVideoCell") as! SuggestVideoCell
            let video = searchResult[indexPath.row]
            let url = URL(string: video.thumbnails)
            let data = try? Data(contentsOf: url!)
            cell.thumbnailsImage.image = UIImage(data: data!)
            cell.titleLabel.text = video.title
            cell.channelTitleLabel.text = video.channelTitle
            let date = viewController.convertPublishing(publishedAt: video.publishedAt)
            let publishedAt = viewController.getElapsedInterval(date: date)
            cell.publishedAtLabel.text = "\(video.viewCount) views \u{2022} \(publishedAt)"
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == suggestionTableView {
            let suggestion = suggestions[indexPath.row]
            searchBarText = suggestion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            requestSearchResult()
            suggestionTableView.isHidden = true
            resultVideoTableView.isHidden = false
        } else if tableView == resultVideoTableView {
            let video = searchResult[indexPath.row]
            let detailVideo: DetailVideoViewController = storyboard?.instantiateViewController(withIdentifier: "DetailVideoViewController") as! DetailVideoViewController
            detailVideo.detailVideo = video
            detailVideo.requestChannel()
            
            self.navigationController?.pushViewController(detailVideo, animated: true)
            HistoryManager.savedVideo(video: video)
        }
    }
}
