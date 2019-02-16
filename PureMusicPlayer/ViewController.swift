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
            }
            self.artistLabel.text = self.player.currentArtist
            self.albumLabel.text = self.player.currentAlbumTitle
            self.titleLabel.text = self.player.currentTitle
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
    }
    

    @IBAction func browseButtonPushed(_ sender: UIButton) {
        let picker: MPMediaPickerController = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = true
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func togglePlayPauseButtonPushed(_ sender: UIButton) {
        if player.playingNow {
            player.pause()
        } else if player.canPlay {
            player.play()
        }
        togglePlayPauseButtonSetCurrentStatus()
    }
    
    
    @IBAction func stopButtonPushed(_ sender: UIButton) {
        player.stop()
        
        artworkView.image = defaultArtwork
        artistLabel.text = "Artist"
        albumLabel.text = "Album"
        titleLabel.text = "Title"
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
    
    
    func thisFunctionCallWhenMusicPaused() {
        togglePlayPauseButtonSetCurrentStatus()
        pauseWhenCurrentMusicFinishedSwitchSetCurrentStatus()
    }
    
    
    func thisFunctionCallWhenMusicStopped() {
        togglePlayPauseButtonSetCurrentStatus()
        pauseWhenCurrentMusicFinishedSwitchSetCurrentStatus()
    }
}
