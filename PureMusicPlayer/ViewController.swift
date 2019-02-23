//
//  ViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/02/15.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var artworkView: UIImageView!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var albumLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var pauseWhenCurrentMusicFinishedSwitch: UISwitch!
  @IBOutlet weak var hideOfMetaDataSwitch: UISwitch!
  @IBOutlet weak var togglePlayPauseButton: UIButton!
  
  @IBOutlet weak var Re_initAudioUnitButton: UIButton!
  
  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  
  
  func showMetaData() {
    if UserDefaults.standard.bool(forKey: "hideMetaDataIsEnable") { // "曲名を隠す"がONだったら
      if let defaultArtwork: UIImage = UIImage.init(named: "defaultArtwork") { // デフォルトのアートワークを用意できたら、
        artworkView.image = defaultArtwork
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
          MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(boundsSize: defaultArtwork.size, requestHandler: { (size) -> UIImage in
            return defaultArtwork
          }),
          MPMediaItemPropertyArtist: "Artist",
          MPMediaItemPropertyAlbumTitle: "Album",
          MPMediaItemPropertyTitle: "Title"]
        
      } else { // デフォルトのアートワークを用意できなかったら、
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
          MPMediaItemPropertyArtist: "Artist",
          MPMediaItemPropertyAlbumTitle: "Album",
          MPMediaItemPropertyTitle: "Title"]
      }
      
      artistLabel.text = "Artist"
      albumLabel.text = "Album"
      titleLabel.text = "Title"
      
    } else if player.canPlay { // "曲名を隠す"がOFFで、プレーヤーの準備ができていたら、
      if let artwork: UIImage = player.currentArtwork.image(at: CGSize(width: 1200, height: 1200)) { // playerのcurrentArtworkをUIImage型に変換できたら、
        artworkView.image = artwork
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
          MPMediaItemPropertyArtwork: player.currentArtwork,
          MPMediaItemPropertyArtist: player.currentArtist,
          MPMediaItemPropertyAlbumTitle: player.currentAlbumTitle,
          MPMediaItemPropertyTitle: player.currentTitle]
        
      } else if let defaultArtwork: UIImage = UIImage.init(named: "defaultArtwork") { // playerのcurrentArtworkをUIImage型に変換出来なくてかつ、デフォルトのアートワークを用意できたら、
        artworkView.image = defaultArtwork
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
          MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(boundsSize: defaultArtwork.size, requestHandler: { (size) -> UIImage in
            return defaultArtwork
          }),
          MPMediaItemPropertyArtist: player.currentArtist,
          MPMediaItemPropertyAlbumTitle: player.currentAlbumTitle,
          MPMediaItemPropertyTitle: player.currentTitle]
      } else { // 上のどれも出来なかったら、
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
          MPMediaItemPropertyArtist: player.currentArtist,
          MPMediaItemPropertyAlbumTitle: player.currentAlbumTitle,
          MPMediaItemPropertyTitle: player.currentTitle]
      }
      
      artistLabel.text = player.currentArtist
      albumLabel.text = player.currentAlbumTitle
      titleLabel.text = player.currentTitle
    }
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
    
    // PureMusicPlayerDelegateからの操作を受け付けるようにする。
    player.delegate = self
    
    showMetaData()
    togglePlayPauseButtonSetCurrentStatus()
  }
  
  
  @IBAction func chooseButtonPushed(_ sender: UIButton) {
    let picker: MPMediaPickerController = MPMediaPickerController()
    picker.delegate = self
    picker.allowsPickingMultipleItems = true
    present(picker, animated: true, completion: nil)
  }
  
  
  @IBAction func togglePlayPauseButtonPushed(_ sender: UIButton) {
    player.togglePlayPause()
  }
  
  
  @IBAction func stopButtonPushed(_ sender: UIButton) {
    player.stop()
  }
  
  
  @IBAction func skipToPreviousButtonPushed(_ sender: UIButton) {
    player.skipToPrevious()
  }
  
  
  @IBAction func skipToNextButtonPushed(_ sender: UIButton) {
    player.skipToNext()
  }
  
  
  @IBAction func re_initAudioUnitButtonPushed(_ sender: UIButton) {
    player.reInitAudioUnit()
  }
  
}


extension ViewController: MPMediaPickerControllerDelegate {
  func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
    defer {
      // 関数を抜けるときに実行されるらしい
      dismiss(animated: true, completion: nil)
    }
    
    player.setPlaylist(mediaItemCollection)
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
    artistLabel.text = "Artist"
    albumLabel.text = "Album"
    titleLabel.text = "Title"
  }
}
