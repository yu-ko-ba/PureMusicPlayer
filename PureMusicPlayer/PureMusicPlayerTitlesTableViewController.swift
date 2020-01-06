//
//  PureMusicPlayerTitlesTableViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/05/05.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit

class PureMusicPlayerTitlesTableViewController: UITableViewController {
  
  @IBOutlet var titlesTableView: UITableView!
  
//  var files: [String: [String: URL]] = [:]
  var files: [String: [Any]] = [:]
  
  var filesNameList: [String] = []
  
  var fontSize: CGFloat?
  
  //  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  let player: PureMusicPlayer = PureMusicPlayer.sharedInstance
  
  
  @objc func dismissWithAnimation() {
    dismiss(animated: true, completion: nil)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    player.delegate = self
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "default close string"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissWithAnimation))
    
    filesNameList += Array(files.keys).sorted()
    
    if let textLabel: UILabel = titlesTableView.dequeueReusableCell(withIdentifier: "titlesCell")?.textLabel {
      fontSize = textLabel.font.pointSize
    }
    
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
    return files.count + 1
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "titlesCell", for: indexPath)
    
    // Configure the cell...
    if indexPath.row == 0 {
      cell.textLabel?.text = "Play All"
      if let size = fontSize {
        cell.textLabel?.font = UIFont.systemFont(ofSize: size * 2)
      }
    } else {
//      if navigationItem.title == player.currentAlbumTitle && [String](files[filesNameList[indexPath.row - 1]]!.keys)[0] == player.currentTitle {
      if navigationItem.title == player.currentAlbumTitle && files[filesNameList[indexPath.row - 1]]?[0] as! String == player.currentTitle {
//        cell.textLabel?.text = "▶︎  " + [String](files[filesNameList[indexPath.row - 1]]!.keys)[0]
        cell.textLabel?.text = "▶︎  " + String(format: "%02d", indexPath.row) + ". " + String(files[filesNameList[indexPath.row - 1]]?[0] as! String)
      } else {
//        cell.textLabel?.text = [String](files[filesNameList[indexPath.row - 1]]!.keys)[0]
        cell.textLabel?.text = String(format: "%02d", indexPath.row) + ". " + String((files[filesNameList[indexPath.row - 1]]?[0] as? String)!)
      }
      
      if let size: CGFloat = fontSize {
        cell.textLabel?.font = UIFont.systemFont(ofSize: size)
      }
    }
    
    cell.textLabel?.adjustsFontSizeToFitWidth = true
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.row == 0 {
      var urls: [URL] = []
      
      var counter: Int = 0
      for key: String in filesNameList {
//        if let url: URL = files[key]?[[String](files[filesNameList[counter]]!.keys)[0]] {
        if let url: URL = files[key]?[1] as? URL {
          urls += [url]
        }
        counter += 1
      }
      
      //      player.setPlayURLList(urls)
      player.setQueue(withURLs: urls)
      dismiss(animated: true, completion: nil)
    } else {
//      if let url: URL = files[filesNameList[indexPath.row - 1]]?[[String](files[filesNameList[indexPath.row - 1]]!.keys)[0]] {
      if let url: URL = files[filesNameList[indexPath.row - 1]]?[1] as? URL {
        //        player.setPlayURLList([url])
        player.setQueue(withURLs: [url])
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


extension PureMusicPlayerTitlesTableViewController: PureMusicPlayerDelegate {
  func thisFunctionIsCalledAtBeginningOfMusic() {
    DispatchQueue.main.async {
      let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "titlesCell", for: IndexPath(row: Int(self.player.currentMusicNumber), section: 0))
      cell.textLabel?.text = "▶︎  " + self.player.currentTitle
      self.titlesTableView.reloadData()
    }
  }
}
