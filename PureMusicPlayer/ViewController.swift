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
    @IBOutlet weak var togglePlayPauseButton: UIButton!
    
    @IBOutlet weak var Re_initAudioUnitButton: UIButton!
    
    let defaultArtwork: UIImage = #imageLiteral(resourceName: "default.png")
    
    let player: PureMusicPlayer = PureMusicPlayer.init()
    
    
    func showMetaData() {
        DispatchQueue.main.async {
            if let artwork = self.player.currentArtwork.image(at: CGSize(width: 1200, height: 1200)) {
                self.artworkView.image = artwork
            } else {
                self.artworkView.image = self.defaultArtwork
            }
            self.artistLabel.text = self.player.currentArtist
            self.albumLabel.text = self.player.currentAlbumTitle
            self.titleLabel.text = self.player.currentTitle
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist: player.currentArtist, MPMediaItemPropertyAlbumTitle: player.currentAlbumTitle, MPMediaItemPropertyTitle: player.currentTitle]
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
    
    
    func pauseWhenCurrentMusicFinishedSwitchSetCurrentStatus() {
        DispatchQueue.main.async {
            self.pauseWhenCurrentMusicFinishedSwitch.setOn(self.player.pauseWhenCurrentMusicFinishedIsEnable, animated: true)
        }
    }
    
    
    @objc func thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchPushed(sender: UISwitch) {
        player.pauseWhenCurrentMusicFinishedIsEnable = sender.isOn
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        artworkView.image = defaultArtwork
        pauseWhenCurrentMusicFinishedSwitch.addTarget(self, action: #selector(thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchPushed(sender:)), for: UIControl.Event.valueChanged)
        
        artistLabel.adjustsFontSizeToFitWidth = true
        albumLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontSizeToFitWidth = true
        
        Re_initAudioUnitButton.titleLabel?.numberOfLines = 2
        
        player.delegate = self
        
        // コントロールセンターの設定
        let commandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { (event) in
            self.player.play()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { (event) in
            self.player.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.togglePlayPauseCommand.addTarget { (event) in
            self.player.togglePlayPause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.stopCommand.addTarget { (event) in
            self.player.stop()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.previousTrackCommand.addTarget { (event) in
            self.player.skipToPrevious()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.nextTrackCommand.addTarget { (event) in
            self.player.skipToNext()
            return MPRemoteCommandHandlerStatus.success
        }
    }
    

    @IBAction func browseButtonPushed(_ sender: UIButton) {
        let picker: MPMediaPickerController = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = true
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func togglePlayPauseButtonPushed(_ sender: UIButton) {
        player.togglePlayPause()
        
//        if player.playingNow {
//            player.pause()
//        } else if player.canPlay {
//            player.play()
//        }
//        togglePlayPauseButtonSetCurrentStatus()
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


extension ViewController: PMPDelegate {
    func thisFunctionIsCalledAtBeginningOfMusic() {
        showMetaData()
    }
    
    
    func thisFunctionCallWhenPlayingStart() {
        togglePlayPauseButtonSetCurrentStatus()
    }
    
    
    func thisFunctionCallWhenMusicPaused() {
        togglePlayPauseButtonSetCurrentStatus()
        pauseWhenCurrentMusicFinishedSwitchSetCurrentStatus()
    }
    
    
    func thisFunctionCallWhenMusicStopped() {
        togglePlayPauseButtonSetCurrentStatus()
        pauseWhenCurrentMusicFinishedSwitchSetCurrentStatus()
        
        artworkView.image = defaultArtwork
        artistLabel.text = "Artist"
        albumLabel.text = "Album"
        titleLabel.text = "Title"
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist: "Artist", MPMediaItemPropertyAlbumTitle: "Album", MPMediaItemPropertyTitle: "Title"]
    }
}
