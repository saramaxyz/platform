//
//  ModelChecker.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

class ModelChecker: ModelCheckerUseCase {
  private let localModelStore: ModelStorable
  
  init(localModelStore: ModelStorable) {
    self.localModelStore = localModelStore
  }
  
  func checkLocalModelVersion(modelName: String, remoteVersion: Int) -> Bool {
    // Get the version of the local model
    if let localVersion = localModelStore.getLocalModelVersion(for: modelName) {
      return localVersion >= remoteVersion
    }
    
    // If the local version is nil, then it needs to be downloaded
    return false
  }
}
