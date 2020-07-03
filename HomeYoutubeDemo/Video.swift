//
//  Video.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 5/14/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import Foundation
import RealmSwift

class Video: Object, Codable {
    dynamic var title: String = ""
    dynamic var thumbnails: String = ""
    dynamic var channelTitle: String = ""
    dynamic var descriptionVideo: String = ""
    dynamic var channelId: String = ""
    dynamic var viewCount: Int = 0
    dynamic var duration: String = ""
    dynamic var publishedAt: String = ""
    dynamic var likeCount: Int = 0
    dynamic var dislikeCount: Int = 0
    
    convenience init(title: String, thumbnails: String, channelTitle: String, descriptionVideo: String, channelId: String, viewCount: Int, duration: String, publishedAt: String, likeCount: Int, dislikeCount: Int) {
        self.init()
        self.title = title
        self.thumbnails = thumbnails
        self.channelTitle = channelTitle
        self.descriptionVideo = descriptionVideo
        self.channelId = channelId
        self.viewCount = viewCount
        self.duration = duration
        self.publishedAt = publishedAt
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
    }
}

