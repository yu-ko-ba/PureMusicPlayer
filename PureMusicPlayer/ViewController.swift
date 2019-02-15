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
    
    let defaultArtwork: UIImage = #imageLiteral(resourceName: "default.png")
    
    let player: PureMusicPlayer = PureMusicPlayer.init()
    
    
    @objc func thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchPushed(sender: UISwitch) {
        player.pauseWhenCurrentMusicFinishedIsEnable = sender.isOn
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        artworkView.image = defaultArtwork
        pauseWhenCurrentMusicFinishedSwitch.isOn = false
        pauseWhenCurrentMusicFinishedSwitch.addTarget(self, action: #selector(thisFunctionCallWhenPauseWhenCurrentMusicFinishedSwitchPushed(sender:)), for: UIControl.Event.valueChanged)
        
        artistLabel.adjustsFontSizeToFitWidth = true
        albumLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontSizeToFitWidth = true
        
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
            
            // ほんとうはいらないはずなんだけどうまく動かないときがあるからそのとき用
            togglePlayPauseButton.setTitle("▶︎", for: UIControl.State())
        } else if player.canPlay {
            player.play()
            togglePlayPauseButton.setTitle("‖", for: UIControl.State())
        }
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
    
}


extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        defer {
            // 関数を抜けるときに実行されるらしい
            dismiss(animated: true, completion: nil)
        }
        
        player.setPlaylist(mediaItemCollection)
        player.play()
        
        togglePlayPauseButton.setTitle("‖", for: UIControl.State())
    }
    
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension ViewController: PMPDelegate {
    func thisFunctionIsCalledAtBeginningOfMusic() {
        if let artwork = player.currentArtwork.image(at: CGSize(width: 1200, height: 1200)) {
            artworkView.image = artwork
        }
        
        artistLabel.text = player.currentArtist
        albumLabel.text = player.currentAlbumTitle
        titleLabel.text = player.currentTitle
    }
    
    
    func thisFunctionCallWhenMusicPaused() {
        togglePlayPauseButton.setTitle("▶︎", for: UIControl.State())
        
        pauseWhenCurrentMusicFinishedSwitch.isOn = player.pauseWhenCurrentMusicFinishedIsEnable
    }
    
    
    func thisFunctionCallWhenMusicStopped() {
        togglePlayPauseButton.setTitle("▶︎", for: UIControl.State())
        artworkView.image = defaultArtwork
        artistLabel.text = "Artist"
        albumLabel.text = "Album"
        titleLabel.text = "Title"
    }
}
