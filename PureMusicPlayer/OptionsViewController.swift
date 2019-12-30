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
  @IBOutlet weak var reinitAudioUnitButton: UIButton!
  @IBOutlet weak var infinityRoopSwitch: UISwitch!
  
  //  let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
  let player: PureMusicPlayer = PureMusicPlayer.sharedInstance
  
  // pauseWhenCurrentMusicFinishedSwitchの値が変更されたときの処理
  @objc func thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchValueChanged(sender: UISwitch) {
    // pauseWhenCurrentMusicFinishedSwitchのオン・オフの値をPureMusicPlayerに渡す
    player.pauseWhenCurrentMusicFinishedIsEnable = sender.isOn
  }
  
  
  // thisFunctionCallWhenHideMetaDataSwitchの値が変更されたときの処理
  @objc func thisFunctionCallWhenHideMetaDataSwitchValueChanged() {
    // UserDefaultsにhideMetaDataSwitchの値を保存する
    //    UserDefaults.standard.set(hideMetaDataSwitch.isOn, forKey: "hideMetaDataIsEnable")
    
    player.hideMetaDataIsEnable = hideMetaDataSwitch.isOn
    
    // コントロールセンターの表示を更新する
    //    player.showMusicDataForInfoCenter()
    player.setCurrentInfoToInfoCenter()
  }
  
  
  @objc func hisFunctionCallWhenHideMetaDataSwitchValueChanged() {
    player.infinityRoopIsEnable = infinityRoopSwitch.isOn
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    player.delegate = self
    
    // pauseWhenCurrentMusicFinishedSwitchがオンのときのスイッチの色を黒にする
    pauseWhenCurrentMusicFinishedSwitch.onTintColor = UIColor.black
    
    // pauseWhenCurrentMusicFinishedSwitchにPureMusicPlayer.pauseWhenCurrentMusicFinishedIsEnableの値を代入する
    pauseWhenCurrentMusicFinishedSwitch.isOn = player.pauseWhenCurrentMusicFinishedIsEnable
    
    // pauseWhenCurrentMusicFinishedSwitchの値が変更されてときにthisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchValueChanged()を実行する
    pauseWhenCurrentMusicFinishedSwitch.addTarget(self, action: #selector(thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchValueChanged(sender:)), for: UIControl.Event.valueChanged)
    
    // hideMetaDataSwitchがオンのときのスイッチの色を黒にする
    hideMetaDataSwitch.onTintColor = UIColor.black
    
    // hideMetaDataSwitchにUserDefaultsのhideMetaDataIsEnableの値を代入する
    //    hideMetaDataSwitch.isOn = UserDefaults.standard.bool(forKey: "hideMetaDataIsEnable")
    hideMetaDataSwitch.isOn = player.hideMetaDataIsEnable
    
    // hideMetaDataSwitchの値が変更されてときにthisFunctionCallWhenHideMetaDataSwitchValueChanged()を実行する
    hideMetaDataSwitch.addTarget(self, action: #selector(thisFunctionCallWhenHideMetaDataSwitchValueChanged), for: UIControl.Event.valueChanged)
    
    infinityRoopSwitch.onTintColor = UIColor.black
    infinityRoopSwitch.isOn = player.infinityRoopIsEnable
    infinityRoopSwitch.addTarget(self, action: #selector(hisFunctionCallWhenHideMetaDataSwitchValueChanged), for: UIControl.Event.valueChanged)
    
    // reInitAudioUnitButtonの角を丸くする
    reinitAudioUnitButton.layer.borderColor = UIColor.black.cgColor
    reinitAudioUnitButton.layer.borderWidth = 2
    reinitAudioUnitButton.layer.cornerRadius = 10
    reinitAudioUnitButton.layer.masksToBounds = true
  }
  
  
  @IBAction func backButtonPushed(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func reInitAudioUnitButtonPushed(_ sender: UIButton) {
    // audioUnitをinitし直す
    //    player.reInitAudioUnit()
    player.reinitAudioUnit()
  }
}


// PureMusicPlayerの再生が停止されたり、一時停止されたときの処理
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
