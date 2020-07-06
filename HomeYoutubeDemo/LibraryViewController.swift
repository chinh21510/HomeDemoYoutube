//
//  LibraryViewController.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/1/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit
import RealmSwift

class LibraryViewController: UIViewController, UITableViewDataSource {
   
    @IBOutlet weak var createPlaylist: UIButton!
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    let realm = try! Realm()
    var namesPlaylist: Results<Playlist>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isHidden = true
        loadPlaylist()
        playlistTableView.dataSource = self
        playlistTableView.register(UINib(nibName: "SuggestionCell", bundle: nil), forCellReuseIdentifier: "SuggestionCell")
    }
    
    @IBAction func createPlaylistButton(_ sender: Any) {
        textField.text = ""
        textView.isHidden = false
        playlistTableView.isHidden = true
    }
    
    @IBAction func createNewPlaylist(_ sender: Any) {
        let newPlaylist = Playlist()
        newPlaylist.name = textField.text!
        try! realm.write {
            realm.add(newPlaylist)
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
        namesPlaylist = realm.objects(Playlist.self).sorted(byKeyPath: "name")
        print(namesPlaylist!)
        playlistTableView.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
}
