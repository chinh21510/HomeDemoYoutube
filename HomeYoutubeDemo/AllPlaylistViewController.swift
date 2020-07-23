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
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textField: UITextField!
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
        playlistTableView.layer.borderWidth = 0.2
        textView.layer.cornerRadius = 10
        textView.isHidden = true
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
            let url = URL(string: namesPlaylist[indexPath.row].favoriteVideos[0].thumbnails)!
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
    
    @IBAction func createNewPlaylist(_ sender: Any) {
        let newPlaylist = Playlist()
        newPlaylist.name = textField.text!
        try! realm!.write {
            realm!.add(newPlaylist)
        }
        textView.isHidden = true
        playlistTableView.isHidden = false
        view.backgroundColor = .white
        playlistTableView.reloadData()
    }
    
    @IBAction func CancelCreateNewPlaylist(_ sender: Any) {
        textView.isHidden = true
        playlistTableView.isHidden = false
        view.backgroundColor = .white
        addPlaylistView.backgroundColor = .white
    }
    
    @IBAction func addNewPlaylistButton(_ sender: Any) {
        textField.text = ""
        textView.isHidden = false
        playlistTableView.isHidden = true
        view.backgroundColor = .systemGray5
        addPlaylistView.backgroundColor = .systemGray5
    }
}
