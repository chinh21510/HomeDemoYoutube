//
//  Video.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 5/14/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import Foundation

struct Video: Codable {
    var title: String
    var thumbnails: String
    let channelTitle: String
    let description: String
    let channelId: String
    var viewCount: Int
    let duration: String
    let publishedAt: String
    var likeCount: Int
    var dislikeCount: Int
}

