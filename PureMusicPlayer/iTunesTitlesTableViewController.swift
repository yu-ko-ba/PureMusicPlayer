//
//  TitlesTableViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/05/02.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit

class iTunesTitlesTableViewController: UITableViewController {
  @IBOutlet var titlesTableView: UITableView!
  
  var collection: MPMediaItemCollection?
  var fontSize: CGFloat?
  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  
  
  @objc func dismissWithAnimation() {
    dismiss(animated: true, completion: nil)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    player.delegate = self
    
    if let textLabel: UILabel = titlesTableView.dequeueReusableCell(withIdentifier: "titlesCell")?.textLabel {
      fontSize = textLabel.font.pointSize
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissWithAnimation))
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
    guard let count: Int = collection?.count else { return 0 }
    
    return count + 1
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "titlesCell", for: indexPath)
    
    // Configure the cell...
    if indexPath.row == 0 {
      cell.textLabel?.text = "Play All"
      if let size: CGFloat = fontSize {
        cell.textLabel?.font = UIFont.systemFont(ofSize: size * 2)
      }
    } else {
      if collection?.items[indexPath.row - 1].albumTitle == player.currentAlbumTitle && collection?.items[indexPath.row - 1].title == player.currentTitle {
        cell.textLabel?.text = "▶︎  " + player.currentTitle
      } else {
        cell.textLabel?.text = collection?.items[indexPath.row - 1].title
      }
      
      if let size: CGFloat = fontSize {
        cell.textLabel?.font = UIFont.systemFont(ofSize: size)
      }
    }
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      if let playlist: MPMediaItemCollection = collection {
        player.setPlaylist(playlist)
        dismiss(animated: true, completion: nil)
      } else {
        print("collectionの値がnilです。")
      }
    } else {
      if let item: MPMediaItem = collection?.items[indexPath.row - 1] {
        player.setPlaylist(MPMediaItemCollection(items: [item]))
      } else {
        print("collectionからitemを取得できませんでした。")
      }
    }
    
    player.play()
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


extension iTunesTitlesTableViewController: PureMusicPlayerDelegate {
  func thisFunctionIsCalledAtBeginningOfMusic() {
    DispatchQueue.main.async {
      let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "titlesCell", for: IndexPath(row: Int(self.player.currentMusicNumber), section: 0))
      cell.textLabel?.text = "▶︎  " + self.player.currentTitle
      self.titlesTableView.reloadData()
    }
  }
}
