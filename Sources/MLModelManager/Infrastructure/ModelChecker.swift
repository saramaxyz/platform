//
//  ModelChecker.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public class ModelChecker: ModelCheckerUseCase {
  private let localModelStore: ModelStorable
  
  public init(localModelStore: ModelStorable) {
    self.localModelStore = localModelStore
  }
  
  public func checkLocalModelVersion(model: ModelEntity) -> Bool {
    // If no local version is available, return false
    if localModelStore.getLocalModelVersion(for: model.id) == nil {
      return false
    }
    
    // Get the version of the local model
    if let localVersion = localModelStore.getLocalModelVersion(for: model.id) {
      return localVersion >= model.version
    }
    
    // If the local version is nil, then it needs to be downloaded
    return false
  }
}
