//
//  MLModelManager.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 21/09/2023.
//

import Foundation

public extension MLModelManager {
  static func makeWithSupabase(baseURL: URL,
                               apiKey: String) -> MLModelManager {
    let modelStore = ModelLocalStore()
    let modelDownloader = ModelDownloader(modelStore: modelStore)
    let manager = MLModelManager(modelChecker: ModelChecker(localModelStore: modelStore),
                                 modelCompiler: ModelCompiler(),
                                 modelDownloader: modelDownloader,
                                 localModelStore: modelStore,
                                 modelServer: SupabaseModelServer(baseURL: baseURL, apiKey: apiKey))
    
    modelDownloader.delegate = manager
    
    return manager
  }
}
