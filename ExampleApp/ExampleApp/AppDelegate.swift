//
//  AppDelegate.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 22/09/2023.
//

import UIKit
import AeroEdge

class AppDelegate: NSObject, UIApplicationDelegate {
  let aeroEdge: AeroEdge = .make(apiKey: "your_token_here")
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    if identifier == AeroEdge.backgroundIdentifier {
      aeroEdge.backgroundSessionCompletionHandler = completionHandler
    }
  }
}
