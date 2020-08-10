//
//  AllPlaylistViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/16/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift
class AllPlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var addNewPlaylistButton: UIButton!
    @IBOutlet weak var addPlaylistView: UIView!
    
    let realm = try? Realm()
    var namesPlaylist: Results<Playlist>!
    var playlistVideo: Results<Video>!
    var playlist: Playlist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
        playlistTableView.register(UINib(nibName: "AllPlaylistCell", bundle: nil), forCellReuseIdentifier: "AllPlaylistCell")
        setupUI()
    }
    
    func setupUI() {
        playlistTableView.rowHeight = 100
        playlistTableView.layer.borderWidth = 0.15
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Playlists"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        if let playlist = namesPlaylist?[indexPath.row] {
            try! realm!.write {
                realm!.delete(playlist)
            }
        }
        self.playlistTableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesPlaylist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTableView.dequeueReusableCell(withIdentifier: "AllPlaylistCell") as! AllPlaylistCell
        cell.playlistImageView.contentMode = UIView.ContentMode.scaleAspectFill
        cell.namePlaylistLabel.text = namesPlaylist?[indexPath.row].name ?? ""
        cell.numberOfVideoLabel.text = "\(namesPlaylist[indexPath.row].favoriteVideos.count) Videos"
        if namesPlaylist[indexPath.row].favoriteVideos.count != 0 {
            let url = URL(string: namesPlaylist[indexPath.row].favoriteVideos.last!.thumbnails)!
            let data = try? Data(contentsOf: url)
            cell.playlistImageView.image = UIImage(data: data!)
        } else {
            cell.playlistImageView.image = UIImage(named: "video1")
            if cell.playlistImageView.image == UIImage(named: "video1") {
            }
        }
        cell.playlistImageView.layer.cornerRadius = 10
        cell.playlistImageView.layer.masksToBounds = true
        return cell
    }
    
    @IBAction func addNewPlaylistButton(_ sender: Any) {
      let alert: UIAlertController = UIAlertController(title: "New Playlist", message: "Enter a name for this playlist", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter a name"
        }
        let createButton: UIAlertAction = UIAlertAction(title: "Create", style: .cancel) { (button) in
            let newPlaylist = Playlist()
            newPlaylist.name = alert.textFields![0].text!
            try! self.realm!.write {
                self.realm!.add(newPlaylist)
            }
            self.playlistTableView.reloadData()
        }
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(createButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
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
