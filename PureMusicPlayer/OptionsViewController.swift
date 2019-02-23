//
//  OptionsViewController.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/02/23.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
  
  @IBOutlet weak var pauseWhenCurrentMusicFinishedSwitch: UISwitch!
  @IBOutlet weak var hideMetaDataSwitch: UISwitch!
  
  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  
  
  @objc func thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchPushed(sender: UISwitch) {
    player.pauseWhenCurrentMusicFinishedIsEnable = sender.isOn
  }
  
  
  @objc func thisFunctionCallWhenHideMetaDataSwitchValueChanged() {
    UserDefaults.standard.set(hideMetaDataSwitch.isOn, forKey: "hideMetaDataIsEnable")
    
    if UserDefaults.standard.bool(forKey: "hideMetaDataIsEnable") { // "曲名を隠す"がONだったら
      if let defaultArtwork: UIImage = UIImage.init(named: "defaultArtwork") { // デフォルトのアートワークを用意できたら、
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
    } else if player.canPlay { // "曲名を隠す"がOFFで、プレーヤーの準備ができていたら、
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyArtwork: player.currentArtwork,
        MPMediaItemPropertyArtist: player.currentArtist,
        MPMediaItemPropertyAlbumTitle: player.currentAlbumTitle,
        MPMediaItemPropertyTitle: player.currentTitle]
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    pauseWhenCurrentMusicFinishedSwitch.isOn = player.pauseWhenCurrentMusicFinishedIsEnable
    pauseWhenCurrentMusicFinishedSwitch.addTarget(self, action: #selector(thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchPushed(sender:)), for: UIControl.Event.valueChanged)

    hideMetaDataSwitch.isOn = UserDefaults.standard.bool(forKey: "hideMetaDataIsEnable")
    hideMetaDataSwitch.addTarget(self, action: #selector(thisFunctionCallWhenHideMetaDataSwitchValueChanged), for: UIControl.Event.valueChanged)
  }
  
  
    @IBAction func reInitAudioUnitButtonPushed(_ sender: UIButton) {
      player.reInitAudioUnit()
    }
}


extension OptionsViewController: PureMusicPlayerDelegate {
  func thisFunctionCallWhenMusicPaused() {
    DispatchQueue.main.async {
      self.pauseWhenCurrentMusicFinishedSwitch.setOn(self.player.pauseWhenCurrentMusicFinishedIsEnable, animated: true)
    }
  }
  
  
  func thisFunctionCallWhenMusicStopped() {
    DispatchQueue.main.async {
      self.pauseWhenCurrentMusicFinishedSwitch.setOn(self.player.pauseWhenCurrentMusicFinishedIsEnable, animated: true)
    }
  }
}
