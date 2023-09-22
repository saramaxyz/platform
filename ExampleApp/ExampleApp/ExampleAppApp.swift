//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 20/09/2023.
//

import SwiftUI

@main
struct ExampleAppApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: ViewModel(mlModelManager: appDelegate.mlModelManager))
    }
  }
}
