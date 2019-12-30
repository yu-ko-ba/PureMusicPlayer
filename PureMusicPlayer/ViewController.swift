//
//  ViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/02/15.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
  
  @IBOutlet weak var artworkView: UIImageView!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var albumLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var togglePlayPauseButton: UIButton!
  
  //  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  let player: PureMusicPlayer = PureMusicPlayer.sharedInstance
  
  
  func showMetaData() {
    //    if UserDefaults.standard.bool(forKey: "hideMetaDataIsEnable") { // "曲名を隠す"がONだったら
    //      if let defaultArtwork: UIImage = UIImage.init(named: "defaultArtwork") { // デフォルトのアートワークを用意できたら、
    //        artworkView.image = defaultArtwork
    //      }
    //      artistLabel.text = NSLocalizedString("Artist", comment: "default artist string")
    //      albumLabel.text = NSLocalizedString("Album", comment: "default album string")
    //      titleLabel.text = NSLocalizedString("Title", comment: "default title string")
    //    } else if player.canPlay { // "曲名を隠す"がOFFで、プレーヤーの準備ができていたら、
    //      if let artwork: UIImage = player.currentArtwork.image(at: CGSize(width: 1200, height: 1200)) { // playerのcurrentArtworkをUIImage型に変換できたら、
    //        artworkView.image = artwork
    //      } else if let defaultArtwork: UIImage = UIImage.init(named: "defaultArtwork") { // playerのcurrentArtworkをUIImage型に変換出来なくてかつ、デフォルトのアートワークを用意できたら、
    //        artworkView.image = defaultArtwork
    //      }
    //      artistLabel.text = player.currentArtist
    //      albumLabel.text = player.currentAlbumTitle
    //      titleLabel.text = player.currentTitle
    //    }
    
    artworkView.image = player.artworkImage()
    artistLabel.text = player.artistName()
    albumLabel.text = player.albumTitle()
    titleLabel.text = player.musicTitle()
  }
  
  
  func togglePlayPauseButtonSetCurrentStatus() {
    DispatchQueue.main.async {
      if self.player.playingNow {
        self.togglePlayPauseButton.setTitle("‖", for: UIControl.State())
      } else {
        self.togglePlayPauseButton.setTitle("▶︎", for: UIControl.State())
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // アーティスト名、アルバム名、タイトル名のそれぞれのラベルのフォントサイズを、枠に収まりきるようにする。
    artistLabel.adjustsFontSizeToFitWidth = true
    albumLabel.adjustsFontSizeToFitWidth = true
    titleLabel.adjustsFontSizeToFitWidth = true
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    // dismiss()で帰ってきたときはviewDidLoad()が呼ばれないからdismiss()で帰ってきたときも必要な処理はここに書く。
    // PureMusicPlayerDelegateからの操作を受け付けるようにする。
    player.delegate = self
    
    showMetaData()
    togglePlayPauseButtonSetCurrentStatus()
  }
  
  
  @IBAction func chooseButtonPushed(_ sender: UIButton) {
    //    let picker: MPMediaPickerController = MPMediaPickerController()
    //    picker.delegate = self
    //    picker.allowsPickingMultipleItems = true
    //    present(picker, animated: true, completion: nil)
  }
  
  
  @IBAction func togglePlayPauseButtonPushed(_ sender: UIButton) {
    player.togglePlayPause()
  }
  
  
  @IBAction func skipToPreviousButtonPushed(_ sender: UIButton) {
    player.skipToPrevious()
  }
  
  
  @IBAction func skipToNextButtonPushed(_ sender: UIButton) {
    player.skipToNext()
  }
}


extension ViewController: MPMediaPickerControllerDelegate {
  func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
    defer {
      // 関数を抜けるときに実行されるらしい
      dismiss(animated: true, completion: nil)
    }
    
    //    player.setPlaylist(mediaItemCollection)
    player.setQueue(withMPMediaItemCollection: mediaItemCollection)
    player.play()
    
    togglePlayPauseButtonSetCurrentStatus()
  }
  
  
  func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
    dismiss(animated: true, completion: nil)
  }
}


extension ViewController: PureMusicPlayerDelegate {
  func thisFunctionIsCalledAtBeginningOfMusic() {
    DispatchQueue.main.async {
      self.showMetaData()
    }
  }
  
  
  // 曲の先頭での処理。
  func thisFunctionCallWhenPlayingStart() {
    togglePlayPauseButtonSetCurrentStatus()
  }
  
  
  // 再生が一時停止されたときの処理。
  func thisFunctionCallWhenMusicPaused() {
    togglePlayPauseButtonSetCurrentStatus()
  }
  
  
  // 再生が停止されたときの処理。
  func thisFunctionCallWhenMusicStopped() {
    togglePlayPauseButtonSetCurrentStatus()
    
    if let defaultArtwork: UIImage = UIImage.init(named: "defaultArtwork") {
      artworkView.image = defaultArtwork
    }
    artistLabel.text = NSLocalizedString("Artist", comment: "default artist string")
    albumLabel.text = NSLocalizedString("Album", comment: "default album string")
    titleLabel.text = NSLocalizedString("Title", comment: "default title string")
  }
}
