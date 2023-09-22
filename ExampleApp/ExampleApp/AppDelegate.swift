//
//  AppDelegate.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 22/09/2023.
//

import UIKit
import MLModelManager

class AppDelegate: NSObject, UIApplicationDelegate {
  let mlModelManager: MLModelManager = .make(apiKey: "your_token_here")
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    if identifier == MLModelManager.backgroundIdentifier {
      mlModelManager.backgroundSessionCompletionHandler = completionHandler
    }
  }
}
