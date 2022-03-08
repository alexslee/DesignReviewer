//
//  AppDelegate.swift
//  DesignReviewerExample
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit
import DesignReviewer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    /*
     Example of adding a custom attribute that will be fetched for inspection. Note: this can be done at
     any point really, as the internal setup uses a Set. Abstracting it to something that happens
     at launch (as well as behind any debug-only flags you may wish to configure) is your perogative.
     */
    DesignReviewer.addCustomAttribute(DesignReviewCustomAttribute(title: "Dummy Try", keyPath: "dummyString"),
                                      to: UILabel.self)
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}
