//
//  LibraryViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/1/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var createPlaylist: UIButton!
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textField: UITextField!
    let realm = try? Realm()
    var namesPlaylist: Results<Playlist>!
    var playlistVideo: Results<Video>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isHidden = true
        loadPlaylist()
        playlistTableView.dataSource = self
        playlistTableView.register(UINib(nibName: "SuggestionCell", bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        playlistTableView.delegate = self
        setupUI()
    }
    
    func setupUI() {
        textView.layer.cornerRadius = 10
    }
    
    @IBAction func createPlaylistButton(_ sender: Any) {
        textField.text = ""
        textView.isHidden = false
        playlistTableView.isHidden = true
    }
    
    @IBAction func cancelCreatePlaylistButton(_ sender: Any) {
        textView.isHidden = true
        playlistTableView.isHidden = false
    }
    
    @IBAction func createNewPlaylist(_ sender: Any) {
        let newPlaylist = Playlist()
        newPlaylist.name = textField.text!
        try! realm!.write {
            realm!.add(newPlaylist)
        }
        textView.isHidden = true
        playlistTableView.isHidden = false
        playlistTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesPlaylist?.count ?? 1
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTableView.dequeueReusableCell(withIdentifier: "SuggestionCell") as! SuggestionCell
        cell.suggestionLabel.text = namesPlaylist?[indexPath.row].name ?? ""
        return cell
    }
    
    func loadPlaylist() {
        namesPlaylist = realm!.objects(Playlist.self).sorted(byKeyPath: "name")
        playlistTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist: PlaylistViewController = storyboard?.instantiateViewController(withIdentifier: "PlaylistViewController") as! PlaylistViewController
        playlist.namePlaylist = namesPlaylist[indexPath.row].name
        for video in namesPlaylist[indexPath.row].favoriteVideos {
            playlist.videos.insert(video, at: 0)
        }
        self.navigationController?.pushViewController(playlist, animated: true)
    }
    
    
    
    
}
