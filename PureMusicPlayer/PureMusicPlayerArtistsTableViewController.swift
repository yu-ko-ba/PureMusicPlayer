//
//  PureMusicPlayerArtistsTableViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/05/05.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit
import AVFoundation

class PureMusicPlayerArtistsTableViewController: UITableViewController {
  
  @IBOutlet var artistsTableView: UITableView!
  
//  var musicLibrary: [String: [String: [String: [String: URL]]]] = [:]
  //                 artists  albums  fileNames titles  URLs
  
  var artistsList: [String] = []
  
  //  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  let player: PureMusicPlayer = PureMusicPlayer.sharedInstance
  
  
  @objc func dismissWithAnimation() {
    dismiss(animated: true, completion: nil)
  }
  
  
//  func setToMusicLibrary(url: URL) {
//    var artistName: String = url.pathComponents[url.pathComponents.count - 3]
//    var albumName: String = url.pathComponents[url.pathComponents.count - 2]
//    var titleName: String = url.lastPathComponent
//
//    let fileName: String = url.lastPathComponent
//
//    let asset: AVAsset = AVAsset(url: url)
//    for metaData in asset.metadata {
//      switch metaData.commonKey {
//      case AVMetadataKey.commonKeyArtist:
//        if let artist: String = metaData.value as? String {
//          artistName = artist
//        }
//      case AVMetadataKey.commonKeyAlbumName:
//        if let album: String = metaData.value as? String {
//          albumName = album
//        }
//      case AVMetadataKey.commonKeyTitle:
//        if let title: String = metaData.value as? String {
//          titleName = title
//        }
//      default:
//        break
//      }
//    }
//
//    if albumName == "Documents" {
//      artistName = "Unknown"
//      albumName = "Unknown"
//    }
//
//    if musicLibrary[artistName] == nil {
//      musicLibrary[artistName] = [albumName: [fileName: [titleName: url]]]
//    }
//    if musicLibrary[artistName]?[albumName] == nil {
//      musicLibrary[artistName]?[albumName] = [fileName: [titleName: url]]
//    }
//    musicLibrary[artistName]?[albumName]?[fileName] = [titleName: url]
//  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "default close string"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissWithAnimation))
    
//    let fileManager: FileManager = FileManager.default
//    
//    let documentsPath: String = NSHomeDirectory() + "/Documents"
//    
//    if let objects: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: documentsPath) {
//      while let subPath: String = objects.nextObject() as? String {
//        if let fileType = objects.fileAttributes?[FileAttributeKey.type] as? FileAttributeType {
//          if fileType != FileAttributeType.typeDirectory {
//            let fullPath: String = documentsPath + "/" + subPath
//            let url: URL = URL(fileURLWithPath: fullPath)
//            switch url.pathExtension {
//            case "3gp": break
//            case "3g2": break
//            case "aac": break
//            case "avi": break
//            case "m2ts": break
//            case "m4a": break
//            case "m4b": break
//            case "m4p": break
//            case "mov": break
//            case "mp4": break
//            case "wav": break
//            case "mkv": break
//            case "mka": break
//            case "mp3": break
//            case "alac": break
//            case "flac": break
//            case "ac3": break
//            case "vob": break
//            default:
//              continue
//            }
//            setToMusicLibrary(url: url)
//          }
//        } else {
//          print("ファイルタイプの取得に失敗しました。")
//        }
//      }
//    } else {
//      print("\"~/Documents/*\"の取得に失敗しました。")
//    }
    
    artistsList = Array(player.musics.keys).sorted()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    artistsTableView.reloadData()
  }
  
  
  // MARK: - Table view data source
  
  //    override func numberOfSections(in tableView: UITableView) -> Int {
  //        // #warning Incomplete implementation, return the number of sections
  //        return 0
  //    }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return artistsList.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "artistsCell", for: indexPath)
    
    // Configure the cell...
    if artistsList[indexPath.row] == player.currentArtist {
      cell.textLabel?.text = "▶︎  " + player.currentArtist
    } else {
      cell.textLabel?.text = artistsList[indexPath.row]
    }
    
    cell.textLabel?.adjustsFontSizeToFitWidth = true
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if let pureMusicPlayerAlbumsTableViewController: PureMusicPlayerAlbumsTableViewController = storyboard?.instantiateViewController(withIdentifier: "pureMusicPlayerAlbumsTableViewController") as? PureMusicPlayerAlbumsTableViewController {
//      if let albums: [String: [String: [String: URL]]] = musicLibrary[artistsList[indexPath.row]] {
      if let albums: [String: [String: [Any]]] = player.musics[artistsList[indexPath.row]] {
        pureMusicPlayerAlbumsTableViewController.albums = albums
        pureMusicPlayerAlbumsTableViewController.navigationItem.title = artistsList[indexPath.row]
        
        navigationController?.pushViewController(pureMusicPlayerAlbumsTableViewController, animated: true)
      }
    }
  }
  
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
