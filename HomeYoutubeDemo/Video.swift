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
    @objc dynamic var title: String = ""
    @objc dynamic var thumbnails: String = ""
    @objc dynamic var channelTitle: String = ""
    @objc dynamic var descriptionVideo: String = ""
    @objc dynamic var channelId: String = ""
    @objc dynamic var viewCount: Int = 0
    @objc dynamic var duration: String = ""
    @objc dynamic var publishedAt: String = ""
    @objc dynamic var likeCount: Int = 0
    @objc dynamic var dislikeCount: Int = 0
    @objc dynamic var id: String = ""
    
    convenience init(title: String, thumbnails: String, channelTitle: String, descriptionVideo: String, channelId: String, viewCount: Int, duration: String, publishedAt: String, likeCount: Int, dislikeCount: Int, id: String) {
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
        self.id = id
    }
}

