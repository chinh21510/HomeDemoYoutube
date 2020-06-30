//
//  HistoryManager.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/23/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

class HistoryManager {
    static func savedVideo(video: Video) {
        var videos = loadedVideo()
        videos.insert(video, at: 0)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(videos) {
            UserDefaults.standard.set(encoded, forKey: "History")
        }
    }
    
    static func loadedVideo() -> [Video] {
        var videos = [Video]()
        if let savedVideo = UserDefaults.standard.object(forKey: "History") as? Data {
            let decoder = JSONDecoder()
            if let loadedVideo = try? decoder.decode([Video].self, from: savedVideo) {
                videos = loadedVideo
            }
        }
        return videos
    }
}
