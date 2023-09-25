//
//  AeroEdge.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 21/09/2023.
//

import Foundation

public extension AeroEdge {
  static func makeWithSupabase(baseURL: URL,
                               apiKey: String) -> AeroEdge {
    make(modelSever: SupabaseModelServer(baseURL: baseURL, apiKey: apiKey))
  }

  static func make(apiKey: String) -> AeroEdge {
    make(modelSever: AeroEdgeModelServer(apiKey: apiKey))
  }
  
  static func make(modelSever: ModelServer) -> AeroEdge {
    let modelStore = ModelLocalStore()
    let modelDownloader = ModelDownloader(modelStore: modelStore)
    let manager = AeroEdge(modelChecker: ModelChecker(localModelStore: modelStore),
                                 modelCompiler: ModelCompiler(),
                                 modelDownloader: modelDownloader,
                                 localModelStore: modelStore,
                                 modelServer: modelSever)
    
    modelDownloader.delegate = manager
    
    return manager
  }
}
