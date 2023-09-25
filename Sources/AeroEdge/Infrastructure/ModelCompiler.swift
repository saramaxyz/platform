//
//  ModelCompiler.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation
import CoreML

class ModelCompiler: ModelCompilerUseCase {
  private let fileManager: FileManager
  
  init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }
  
  func compileModel(model: ModelEntity, from localURL: URL) async throws -> MLModel {
    // Create a URL for the compiled model
    let applicationSupportDirectoryURL = try fileManager.url(for: .applicationSupportDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: true)
    let compiledModelURL = applicationSupportDirectoryURL.appendingPathComponent("\(model.versionedName).mlmodelc")
    
    // Check if the compiled model already exists, if yes, then return it
    if fileManager.fileExists(atPath: compiledModelURL.path) {
      let compiledModel = try MLModel(contentsOf: compiledModelURL)
      return compiledModel
    }
    
    // If not, then compile the model from the localURL
    do {
      let tempCompiledURL = try await MLModel.compileModel(at: localURL)
      
      // Move the compiled model from the temp location to our application support directory
      try fileManager.moveItem(at: tempCompiledURL, to: compiledModelURL)
      
      let compiledModel = try MLModel(contentsOf: compiledModelURL)
      return compiledModel
    } catch {
      throw error
    }
  }
}
