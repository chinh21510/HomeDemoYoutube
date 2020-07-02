//
//  Playlist.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/30/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import Foundation
import RealmSwift
/*
 
 Playist: videos
 
 Video
 
 Playlist
 
 Query
 
 Core Data
 Realm
 
 Class Video - Thoa man abc
 Luu Video
 Lay video
 
 
 Class Video: Object {
    var playistId: ....
 }
 
 playist
 
 
 query videos: video.playlistId = playlist.id
 
 */

class Playlist: Object {
    @objc dynamic var name: String = ""
//    let favoriteVideos = List<Video>()
}
