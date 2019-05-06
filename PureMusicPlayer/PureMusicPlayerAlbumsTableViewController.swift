//
//  PureMusicPlayerAlbumsTableViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/05/05.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit

class PureMusicPlayerAlbumsTableViewController: UITableViewController {
  
  var albums: [String: [String: URL]] = [:]
  var albumsTitleList: [String] = []
  
  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  
  
  @objc func dismissWithAnimation() {
    dismiss(animated: true, completion: nil)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissWithAnimation))
    
    albumsTitleList += Array(albums.keys).sorted()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  // MARK: - Table view data source
  
  //    override func numberOfSections(in tableView: UITableView) -> Int {
  //        // #warning Incomplete implementation, return the number of sections
  //        return 0
  //    }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return albumsTitleList.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "albumsCell", for: indexPath)
    
    // Configure the cell...
    if albumsTitleList[indexPath.row] == player.currentAlbumTitle {
      cell.textLabel?.text = "▶︎  " + player.currentAlbumTitle
    } else {
      cell.textLabel?.text = albumsTitleList[indexPath.row]
    }
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if let pureMusicPlayerTitlesTableViewController: PureMusicPlayerTitlesTableViewController = storyboard?.instantiateViewController(withIdentifier: "pureMusicPlayerTitlesTableViewController") as? PureMusicPlayerTitlesTableViewController {
      if let files: [String: URL] = albums[albumsTitleList[indexPath.row]] {
        pureMusicPlayerTitlesTableViewController.files = files
        pureMusicPlayerTitlesTableViewController.navigationItem.title = albumsTitleList[indexPath.row]
        
        navigationController?.pushViewController(pureMusicPlayerTitlesTableViewController, animated: true)
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
