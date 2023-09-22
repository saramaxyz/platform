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
    make(modelSever: SupabaseModelServer(baseURL: baseURL, apiKey: apiKey))
  }

  static func make(apiKey: String) -> MLModelManager {
    make(modelSever: AeroEdgeModelServer(apiKey: apiKey))
  }
  
  static func make(modelSever: ModelServer) -> MLModelManager {
    let modelStore = ModelLocalStore()
    let modelDownloader = ModelDownloader(modelStore: modelStore)
    let manager = MLModelManager(modelChecker: ModelChecker(localModelStore: modelStore),
                                 modelCompiler: ModelCompiler(),
                                 modelDownloader: modelDownloader,
                                 localModelStore: modelStore,
                                 modelServer: modelSever)
    
    modelDownloader.delegate = manager
    
    return manager
  }
}
