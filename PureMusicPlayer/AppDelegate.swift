//
//  AppDelegate.swift
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/02/15.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    // コントロールセンターからの操作を受け付けるようにする。
    let player: PureMusicPlayer = PureMusicPlayer.sharedManager()
    let commandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    commandCenter.playCommand.addTarget { (event) in
      player.play()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.pauseCommand.addTarget { (event) in
      player.pause()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.togglePlayPauseCommand.addTarget { (event) in
      player.togglePlayPause()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.stopCommand.addTarget { (event) in
      player.stop()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.previousTrackCommand.addTarget { (event) in
      player.skipToPrevious()
      return MPRemoteCommandHandlerStatus.success
    }
    commandCenter.nextTrackCommand.addTarget { (event) in
      player.skipToNext()
      return MPRemoteCommandHandlerStatus.success
    }

        
    // 起動したかの確認用
    print("起動しました。")

    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

