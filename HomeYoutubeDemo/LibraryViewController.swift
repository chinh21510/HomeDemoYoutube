//
//  LibraryViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/1/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift

class LibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet weak var playlistCollectionView: UICollectionView!
    @IBOutlet weak var seeAllButton: UIButton!
    
    let realm = try? Realm()
    var namesPlaylist: Results<Playlist>!
    var playlistVideo: Results<Video>!
    var video = Video()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaylist()
        playlistCollectionView.dataSource = self
        playlistCollectionView.register(UINib(nibName: "PlaylistCollectionCell", bundle: nil), forCellWithReuseIdentifier: "PlaylistCollectionCell")
        playlistCollectionView.delegate = self
        setupUI()
        setupNavigationBarItem()
    }
    
    private func setupNavigationBarItem() {
        navigationItem.title = "Library"
    }
    
    func setupUI() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        playlistCollectionView.collectionViewLayout = layout
        playlistCollectionView.heightAnchor.constraint(equalTo: playlistCollectionView.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playlistCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        playlistCollectionView.reloadData()
        return namesPlaylist.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == playlistCollectionView {
            return CGSize(width: playlistCollectionView.frame.width / 3.5, height: playlistCollectionView.frame.width / 2.5)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playlistCollectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCollectionCell", for: indexPath) as! PlaylistCollectionCell
        cell.backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        if indexPath.row == namesPlaylist.count {
            cell.backgroundImage.image = UIImage(named: "plus1")
            cell.backgroundImage.backgroundColor = .systemGray5
            cell.namePlaylistLabel.text = ""
            cell.numberOfVideosLabel.text = ""
            cell.backgroundImage.layer.cornerRadius = 10
            return cell
        } else {
            cell.namePlaylistLabel.text = namesPlaylist?[indexPath.row].name ?? ""
            cell.numberOfVideosLabel.text = "\(namesPlaylist[indexPath.row].favoriteVideos.count) Videos"
            if namesPlaylist[indexPath.row].favoriteVideos.count != 0 {
                let url = URL(string: namesPlaylist[indexPath.row].favoriteVideos.last!.thumbnails)!
                let data = try? Data(contentsOf: url)
                cell.backgroundImage.image = UIImage(data: data!)
            } else {
                cell.backgroundImage.image = UIImage(named: "video1")
                if cell.backgroundImage.image == UIImage(named: "video1") {
                }
            }
            cell.backgroundImage.layer.cornerRadius = 10
            return cell
        }
    }
    
    @IBAction func seeAllButtonTap(_ sender: Any) {
        let allPlaylist: AllPlaylistViewController = storyboard?.instantiateViewController(withIdentifier: "AllPlaylistViewController") as! AllPlaylistViewController
        allPlaylist.namesPlaylist = namesPlaylist
        allPlaylist.playlistVideo = playlistVideo
        self.navigationController?.pushViewController(allPlaylist, animated: true)
    }
    
    func loadPlaylist() {
        namesPlaylist = realm!.objects(Playlist.self).sorted(byKeyPath: "name")
        playlistCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == namesPlaylist.count {
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
                self.playlistCollectionView.reloadData()
            }
            let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(createButton)
            alert.addAction(cancelButton)
            present(alert, animated: true, completion: nil)
        } else {
            if video.title == "" {
                let playlist: PlaylistViewController = storyboard?.instantiateViewController(withIdentifier: "PlaylistViewController") as! PlaylistViewController
                playlist.namesPlaylist = namesPlaylist
                playlist.namePlaylist = namesPlaylist[indexPath.row].name
                for video in namesPlaylist[indexPath.row].favoriteVideos {
                    playlist.videos.insert(video, at: 0)
                }
                self.navigationController?.pushViewController(playlist, animated: true)
            } else {
                try? realm!.write {
                    namesPlaylist[indexPath.row].favoriteVideos.insert(video, at: 0)
                    video = Video()
                }
                playlistCollectionView.reloadData()
            }
        }
    }
}
