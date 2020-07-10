//
//  Playlist.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 6/30/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {
    @objc dynamic var name: String = ""
    let favoriteVideos = List<Video>()
}
