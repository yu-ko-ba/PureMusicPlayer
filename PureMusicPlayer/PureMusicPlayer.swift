//
//  PureMusicPlayer.swift
//  swiftyPMPClass
//
//  Created by Yu Kobayashi on 2019/05/29.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioUnit
import AudioToolbox
import MediaPlayer


class PureMusicPlayer: PureMusicPlayerDelegate {
  var delegate: PureMusicPlayerDelegate?
  
  // アーティスト名がキーの辞書の中にアルバム名がキーの辞書の中にファイル名がキーの辞書の中に0番目がタイトル名、1番目がURLの配列を入れる
  let musics: [String: [String: [String: [Any]]]]
  
  private var audioUnit: AudioUnit!
  private var extAudioFile: ExtAudioFileRef!
  
  private var clientFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
  
  private var playURLs: [URL] = []
  private var playItemCollection: MPMediaItemCollection = MPMediaItemCollection.init(items: [])
  
  private var withMediaItemCollection: Bool = false
  
  private let defaultArtworkImage: UIImage
  private let defaultArtist: String = NSLocalizedString("Artist", comment: "artist string")
  private let defaultAlbumTitle: String = NSLocalizedString("Album", comment: "album string")
  private let defaultTitle: String = NSLocalizedString("Title", comment: "title string")
  
  private(set) var currentArtworkImage: UIImage
  private(set) var currentAlbumArtist: String = "Album Artist"
  private(set) var currentArtist: String = NSLocalizedString("Artist", comment: "artist string")
  private(set) var currentAlbumTitle: String = NSLocalizedString("Album", comment: "album string")
  private(set) var currentTitle: String = NSLocalizedString("Title", comment: "title string")
  
  private(set) var canPlay: Bool = false
  private(set) var playingNow: Bool = false
  
  private(set) var currentMusicNumber: Int = 0
  
  var hideMetaDataIsEnable: Bool = false
  var pauseWhenCurrentMusicFinishedIsEnable: Bool = false
  var infinityRoopIsEnable: Bool = false
  
  
  //MARK: -
  
  // シングルトン実装にする
  static let sharedInstance: PureMusicPlayer = PureMusicPlayer()
  
  private init() {
    // Pure Music Playerフォルダに入ってる曲の情報を取得しておく
    let fileManager: FileManager = FileManager.default
    
    let documentsPath: String = NSHomeDirectory() + "/Documents"
    
    print(documentsPath)
    
    var library: [String: [String: [String: [Any]]]] = [:]
    
    if let objects: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: documentsPath) {
      while let subPath: String = objects.nextObject() as? String {
        if subPath.hasPrefix(".Trash") {
          continue
        }
        
        if let fileType = objects.fileAttributes?[FileAttributeKey.type] as? FileAttributeType {
          if fileType != FileAttributeType.typeDirectory {
            let fullPath: String = documentsPath + "/" + subPath
            let url: URL = URL(fileURLWithPath: fullPath)
            switch url.pathExtension {
            case "3gp": break
            case "3g2": break
            case "aac": break
            case "avi": break
            case "m2ts": break
            case "m4a": break
            case "m4b": break
            case "m4p": break
            case "mov": break
            case "mp4": break
            case "wav": break
            case "mkv": break
            case "mka": break
            case "mp3": break
            case "alac": break
            case "flac": break
            case "ac3": break
            case "vob": break
            default:
              continue
            }
            var artistName: String = url.pathComponents[url.pathComponents.count - 3]
            var albumName: String = url.pathComponents[url.pathComponents.count - 2]
            var titleName: String = url.lastPathComponent
            
            let fileName: String = url.lastPathComponent
            
            let asset: AVAsset = AVAsset(url: url)
            for metaData in asset.metadata {
              switch metaData.identifier {
              case AVMetadataIdentifier.iTunesMetadataAlbumArtist:
                if let artist: String = metaData.stringValue {
                  artistName = artist
                }
              case AVMetadataIdentifier.iTunesMetadataAlbum:
                if let album: String = metaData.stringValue {
                  albumName = album
                }
              case AVMetadataIdentifier.iTunesMetadataSongName:
                if let title: String = metaData.stringValue {
                  titleName = title
                }
              default:
                break
              }
            }
            
//            print("id3-----------------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.id3) {
//              print(metaData.stringValue ?? "---")
//            }

//            print("audioFile-----------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.audioFile) {
//              print(metaData.stringValue ?? "---")
//            }

//            print("common---------------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.common) {
//              print(metaData.stringValue ?? "---")
//            }

//            print("icy------------------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.icy) {
//              print(metaData.stringValue ?? "---")
//            }

//            print("iso------------------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.isoUserData) {
//              print(metaData.stringValue ?? "---")
//            }

//            print("itunes--------------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.iTunes) {
//              if metaData.identifier == AVMetadataIdentifier.iTunesMetadataAlbumArtist {
//                print("Album Artist: " + (metaData.stringValue ?? "---"))
//              }
//              if metaData.identifier == AVMetadataIdentifier.iTunesMetadataAlbum {
//                print("Album       : " + (metaData.stringValue ?? "---"))
//              }
//              if metaData.identifier == AVMetadataIdentifier.iTunesMetadataSongName {
//                print("Title       : " + (metaData.stringValue ?? "---"))
//              }
//            }

//            print("quickTime----------")
//            for metaData in AVMetadataItem.metadataItems(from: asset.metadata, withKey: nil, keySpace: AVMetadataKeySpace.quickTimeMetadata) {
//              print(metaData.stringValue ?? "---")
//            }

//            print("metadata------------")
//            for metaData in asset.metadata {
//              metaData.stringValue
//              metaData.identifier
//              AVMetadataIdentifier.iTunesMetadataAlbumArtist
//              AVMetadataKey.iTunesMetadataKeyAlbumArtist
//              print(metaData.value(forKey: AVMetadataKey.iTunesMetadataKeyAlbumArtist))
//              print(metaData.stringValue ?? "---")
//              print(AVMetadataKey.iTunesMetadataKeyAlbumArtist)
//            }

            if albumName == "Documents" || albumName == "Library" || albumName == "Music" {
              artistName = "Unknown"
              albumName = "Unknown"
            }
            
            if library[artistName] == nil {
              library[artistName] = [albumName: [fileName: [titleName, url]]]
            }
            if library[artistName]?[albumName] == nil {
              library[artistName]?[albumName] = [fileName: [titleName, url]]
            }
            library[artistName]?[albumName]?[fileName] = [titleName, url]
          }
        } else {
          print("ファイルタイプの取得に失敗しました。")
        }
      }
    } else {
      print("\"~/Documents/*\"の取得に失敗しました。")
    }

    musics = library
    
    if let image: UIImage = UIImage.init(named: "defaultArtwork") {
      defaultArtworkImage = image
      currentArtworkImage = image
    } else {
      defaultArtworkImage = UIImage()
      currentArtworkImage = UIImage()
    }
    
    initAudioUnit()
    
    let commandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    commandCenter.playCommand.addTarget { (event) in
      self.play()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.pauseCommand.addTarget { (event) in
      self.pause()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.togglePlayPauseCommand.addTarget { (event) in
      self.togglePlayPause()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.previousTrackCommand.addTarget { (event) in
      self.skipToPrevious()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.nextTrackCommand.addTarget { (event) in
      self.skipToNext()
      return MPRemoteCommandHandlerStatus.success
    }
    
    //    // UserDefaultsからデータを読み込む。
    //    let standard: UserDefaults = UserDefaults.standard
    //
    //    if let urls: [URL] = standard.array(forKey: "playURLs") as? [URL] {
    //      playURLs = urls
    //    }
    //    if let collection: MPMediaItemCollection = standard.object(forKey: "playItemCollection") as? MPMediaItemCollection {
    //      playItemCollection = collection
    //    }
    //    withMediaItemCollection = standard.bool(forKey: "withMediaItemCollection")
    //    currentMusicNumber = standard.integer(forKey: "currentMusicNumber")
    //    hideMetaDataIsEnable = standard.bool(forKey: "hideMetaDataIsEnable")
    //    pauseWhenCurrentMusicFinishedIsEnable = standard.bool(forKey: "pauseWhenCurrentMusicFinishedIsEnable")
    //
    //    print(playURLs)
    //    if playURLs != [] {
    //      if withMediaItemCollection {
    //        prepareToPlay(withURL: playURLs[currentMusicNumber])
    //      }
    //    }
  }
  
  //MARK: -
  
  private func playNext() {
    if pauseWhenCurrentMusicFinishedIsEnable {
      pauseWhenCurrentMusicFinishedIsEnable = false
      pause()
    }
    
    if currentMusicNumber < playURLs.count - 1 {
      currentMusicNumber += 1
    } else {
      if !infinityRoopIsEnable {
        pause()
      }
      currentMusicNumber = 0
    }
    prepareToPlay(withURL: playURLs[currentMusicNumber])
  }
  
  
  private let callback: AURenderCallback = {
    (inRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?)
    in
    // ポインタからPureMusicPlayer型のインスタンスを作成
    let player:PureMusicPlayer = Unmanaged<PureMusicPlayer>.fromOpaque(inRefCon).takeUnretainedValue()
    
    // 値をコピーしておく
    var ioNumberFrames: UInt32 = inNumberFrames
    
    // バッファにデータを読み込む
    ExtAudioFileRead(player.extAudioFile, &ioNumberFrames, ioData!)
    
    if inNumberFrames != ioNumberFrames {
      player.playNext()
    }
    
    return noErr
  }
  
  
  private func initAudioUnit() {
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(AVAudioSession.Category.playback)
      try session.setActive(true)
    } catch let error {
      print("エラー: \(error.localizedDescription)")
    }
    
    var componentDescription: AudioComponentDescription = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
    let audioComponent: AudioComponent = AudioComponentFindNext(nil, &componentDescription)!
    
    AudioComponentInstanceNew(audioComponent, &audioUnit)
    AudioUnitInitialize(audioUnit)
    
    let refCon: UnsafeMutableRawPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    var callbuckStruct: AURenderCallbackStruct = AURenderCallbackStruct(inputProc: callback, inputProcRefCon: refCon)
    
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbuckStruct, UInt32(MemoryLayout.size(ofValue: callbuckStruct)))
  }
  
  //MARK: -
  
  private func prepareToPlay(withURL inURL: URL, callerMethodName: String = #function) {
    var audioFile: ExtAudioFileRef?
    
    ExtAudioFileOpenURL(inURL as CFURL, &audioFile)
    
    if ExtAudioFileOpenURL(inURL as CFURL, &audioFile) != 0 {
      print(inURL)
      print("↑このURLは再生できません")
      
      if callerMethodName == "playNext()" {
        if currentMusicNumber < playURLs.count - 1 {
          skipToNext()
        } else {
          return
        }
      }
      
      if callerMethodName == "setQueue(withURLs:callerMethod:)" {
        var playable: Bool = false
        for i in playURLs {
          if ExtAudioFileOpenURL(i as CFURL, &audioFile) == 0 {
            playable = true
            break
          }
        }
        if !playable {
          return
        }
      }
    }
    
    if callerMethodName == "setQueue(withURLs:callerMethod:)" {
      AudioOutputUnitStop(audioUnit)
      currentMusicNumber = 0
    }
    
    extAudioFile = audioFile
    
    var inFileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
    var sizeOfInFileFormat: UInt32 = UInt32(MemoryLayout.size(ofValue: inFileFormat))
    
    ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_FileDataFormat, &sizeOfInFileFormat, &inFileFormat)
    
    let audioFormat: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: inFileFormat.mSampleRate, channels: inFileFormat.mChannelsPerFrame)!
    clientFormat = audioFormat.streamDescription.pointee
    
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, UInt32(MemoryLayout.size(ofValue: clientFormat)))
    
    ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_ClientDataFormat, UInt32(MemoryLayout.size(ofValue: clientFormat)), &clientFormat)
    
    ExtAudioFileSeek(extAudioFile, 0)
    
    // メタデータの取得
    currentArtworkImage = defaultArtworkImage
    currentArtist = defaultArtist
    currentAlbumTitle = defaultAlbumTitle
    currentTitle = inURL.lastPathComponent
    
    if withMediaItemCollection {
      print(currentMusicNumber)
      let currentItem: MPMediaItem = playItemCollection.items[currentMusicNumber]
      
      if let artwork: MPMediaItemArtwork = currentItem.artwork {
        if let artworkImage: UIImage = artwork.image(at: artwork.bounds.size) {
          currentArtworkImage = artworkImage
        }
      }
      if let albumArtist: String = currentItem.albumArtist {
        currentAlbumArtist = albumArtist
      }
      if let artist: String = currentItem.artist {
        currentArtist = artist
      }
      if let albumTitle: String = currentItem.albumTitle {
        currentAlbumTitle = albumTitle
      }
      if let title: String = currentItem.title {
        currentTitle = title
      }
    } else {
      let asset: AVAsset = AVAsset(url: inURL)
      
      for metaData in asset.metadata {
        switch metaData.commonKey {
        case AVMetadataKey.commonKeyArtwork:
          if let data: Data = metaData.dataValue {
            if let image = UIImage(data: data) {
              currentArtworkImage = image
            }
          }
        case AVMetadataKey.commonKeyArtist:
          if let artist: String = metaData.value as? String {
            currentArtist = artist
          }
        case AVMetadataKey.commonKeyAlbumName:
          if let album: String = metaData.value as? String {
            currentAlbumTitle = album
          }
        case AVMetadataKey.commonKeyTitle:
          if let title: String = metaData.value as? String {
            currentTitle = title
          }
        default:
          break
        }
      }
      
      if currentArtist == defaultArtist {
        currentArtist = inURL.pathComponents[inURL.pathComponents.count - 3]
      }
      if currentAlbumTitle == defaultAlbumTitle {
        currentAlbumTitle = inURL.pathComponents[inURL.pathComponents.count - 2]
      }
      
      if currentAlbumTitle == "Documents" || currentAlbumTitle == "Library" || currentAlbumTitle == "Music" {
        currentArtist = ""
        currentAlbumTitle = ""
      } else if currentArtist == "Documents" || currentAlbumTitle == "Library" || currentAlbumTitle == "Music" {
        currentArtist = ""
      }
      // アルバムアーティストの取得の仕方がわからないからとりあえず
      currentAlbumArtist = currentArtist
    }
    
    canPlay = true
    
    setCurrentInfoToInfoCenter()
    
    delegate?.thisFunctionIsCalledAtBeginningOfMusic()
  }
  
  //MARK: -
  
  func setQueue(withURLs inURLs: [URL], callerMethod: String = #function) {
    guard inURLs.count != 0 else {
      print("再生できるアイテムがありません。")
      return
    }
    
    playURLs = inURLs
    
    if callerMethod == "setQueue(withMPMediaItemCollection:)" {
      withMediaItemCollection = true
    } else {
      withMediaItemCollection = false
    }
    
    prepareToPlay(withURL: playURLs[0])
  }
  
  
  func setQueue(withMPMediaItemCollection inCollection: MPMediaItemCollection) {
    var urls: [URL] = []
    
    for i in inCollection.items {
      guard let url: URL = i.assetURL else {
        print("inCollectionの中に、URLの無いアイテムが含まれるため、処理できません。")
        return
      }
      
      urls += [url]
    }
    
    guard urls.count != 0 else {
      print("再生できるアイテムがありません。")
      return
    }
    
    playItemCollection = inCollection
    
    setQueue(withURLs: urls)
  }
  
  //MARK: -
  
  func play() {
    if canPlay {
      print("再生を開始します。")
      AudioOutputUnitStart(audioUnit)
      playingNow = true
      
      delegate?.thisFunctionCallWhenPlayingStart()
    }
  }
  
  
  func pause() {
    print("再生を一時停止します。")
    AudioOutputUnitStop(audioUnit)
    playingNow = false
    
    delegate?.thisFunctionCallWhenMusicPaused()
  }
  
  
  func togglePlayPause() {
    if playingNow {
      pause()
    } else {
      play()
    }
  }
  
  
  func skipToPrevious() {
    if canPlay {
      var currentSeek: Int64 = 0
      ExtAudioFileTell(extAudioFile, &currentSeek)
      
      if currentSeek >= 30000 {
        ExtAudioFileSeek(extAudioFile, 0)
      } else if currentMusicNumber >= 1 {
        AudioOutputUnitStop(audioUnit)
        currentMusicNumber -= 1
        prepareToPlay(withURL: playURLs[currentMusicNumber])
        AudioOutputUnitStart(audioUnit)
      } else {
        pause()
        ExtAudioFileSeek(extAudioFile, 0)
      }
      
      print("\(currentSeek)フレーム目でスキップしました。")
    }
  }
  
  
  func skipToNext() {
    if canPlay {
      AudioOutputUnitStop(audioUnit)
      playNext()
      
      if playingNow {
        AudioOutputUnitStart(audioUnit)
      }
    }
  }
  
  //MARK: -
  
  func artworkImage() -> UIImage {
    if hideMetaDataIsEnable {
      return defaultArtworkImage
    } else {
      return currentArtworkImage
    }
  }
  
  
  func artistName() -> String {
    if hideMetaDataIsEnable {
      return defaultArtist
    } else {
      return currentArtist
    }
  }
  
  
  func albumTitle() -> String {
    if hideMetaDataIsEnable {
      return defaultAlbumTitle
    } else {
      return currentAlbumTitle
    }
  }
  
  
  func musicTitle() -> String {
    if hideMetaDataIsEnable {
      return defaultTitle
    } else {
      return currentTitle
    }
  }
  
  //MARK: -
  
  func setCurrentInfoToInfoCenter() {
    let center: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var musicInfo: [String : Any] = [:]
    let artwork: MPMediaItemArtwork = MPMediaItemArtwork.init(boundsSize: artworkImage().size) { (size) -> UIImage in
      return self.artworkImage()
    }
    
    musicInfo[MPMediaItemPropertyArtwork] = artwork
    musicInfo[MPMediaItemPropertyArtist] = artistName()
    musicInfo[MPMediaItemPropertyAlbumTitle] = albumTitle()
    musicInfo[MPMediaItemPropertyTitle] = musicTitle()
    
    center.nowPlayingInfo = musicInfo
  }
  
  
  func reinitAudioUnit() {
    AudioOutputUnitStop(audioUnit)
    AudioUnitUninitialize(audioUnit)
    AudioComponentInstanceDispose(audioUnit)
    
    initAudioUnit()
    
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, UInt32(MemoryLayout.size(ofValue: clientFormat)))
    
    if playingNow {
      AudioOutputUnitStart(audioUnit)
    }
  }
  
  
  //  func savePropertiesToUserDefaults() {
  //    print("Hello, World!")
  //
  //    // UserDefaultsに値を保存しておく。
  //    let standard: UserDefaults = UserDefaults.standard
  //
  //    standard.set(playURLs, forKey: "playURLs")
  //    standard.set(playItemCollection, forKey: "playItemCollection")
  //    standard.set(withMediaItemCollection, forKey: "withMediaItemCollection")
  //    standard.set(currentMusicNumber, forKey: "currentMusicNumber")
  //    standard.set(hideMetaDataIsEnable, forKey: "hideMetaDataIsEnable")
  //    standard.set(pauseWhenCurrentMusicFinishedIsEnable, forKey: "pauseWhenCurrentMusicFinishedIsEnable")
  //
  //    standard.synchronize()
  //  }
  
  //MARK: -
  
  deinit {
    AudioOutputUnitStop(audioUnit)
    AudioUnitUninitialize(audioUnit)
    AudioComponentInstanceDispose(audioUnit)
  }
}

//MARK: -

public protocol PureMusicPlayerDelegate {
  func thisFunctionIsCalledAtBeginningOfMusic()
  func thisFunctionCallWhenPlayingStart()
  func thisFunctionCallWhenMusicPaused()
}

extension PureMusicPlayerDelegate {
  func thisFunctionIsCalledAtBeginningOfMusic() {
  }
  func thisFunctionCallWhenPlayingStart() {
  }
  func thisFunctionCallWhenMusicPaused() {
  }
}
