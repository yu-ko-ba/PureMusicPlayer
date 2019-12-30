//
//  iTunesArtistTableViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/11/10.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesArtistTableViewController: UITableViewController {
  
  var collections: [MPMediaItemCollection] = []
  var artistsNameList: [String] = []
  
  let player: PureMusicPlayer = PureMusicPlayer.sharedInstance
  
  @objc func dismissWithAnimation() {
    dismiss(animated: true, completion: nil)
  }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
      
      let albumQuery = MPMediaQuery.init()
      
      let removeCloudItem = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
      albumQuery.addFilterPredicate(removeCloudItem)
      
      if let albumCollections = albumQuery.collections {
        collections = albumCollections
      } else {
        print("アルバム情報の取得に失敗しました。")
      }
      
      for i in collections {
        if let artistName: String = i.representativeItem?.albumArtist {
          if artistsNameList.firstIndex(of: artistName) == nil {
            artistsNameList.append(artistName)
          }
        }
      }
      artistsNameList = artistsNameList.sorted()
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "default close string"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissWithAnimation))
    }

    // MARK: - Table view data source

  /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
 */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return artistsNameList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistsCell", for: indexPath)

        // Configure the cell...
      if artistsNameList[indexPath.row] == player.currentAlbumArtist {
        cell.textLabel?.text = "▶︎  " + player.currentAlbumArtist
      } else {
        cell.textLabel?.text = artistsNameList[indexPath.row]
      }
      
      cell.textLabel?.adjustsFontSizeToFitWidth = true

        return cell
    }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if let albumsTableViewController: iTunesAlbumsTableViewController = storyboard?.instantiateViewController(withIdentifier: "iTunesAlbumsTableViewController") as? iTunesAlbumsTableViewController {
      albumsTableViewController.artistName = artistsNameList[indexPath.row]
      
      navigationController?.pushViewController(albumsTableViewController, animated: true)
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
