//
//  ModelLocalStore.swift
//
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public class ModelLocalStore: ModelStorable {
  private let fileManager: FileManager
  
  public init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }
  
  public func getLocalModelVersion(for modelId: String) -> Int? {
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
      let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
      
      // Filtering files which contain the modelId in their name
      let modelFiles = files.filter { $0.lastPathComponent.contains(modelId) }
      
      // Extracting version numbers and finding the highest version
      let versions = modelFiles.compactMap { url -> Int? in
        let fileName = url.lastPathComponent
        guard let range = fileName.range(of: "\(modelId)_") else { return nil }
        
        let versionString = fileName[range.upperBound...]
        return Int(versionString)
      }
      
      return versions.max()
      
    } catch {
      print("Error while listing files: \(error.localizedDescription)")
      return nil
    }
  }
  
  public func getLocalModelURL(for modelId: String, version: Int) -> URL? {
    let modelNameWithVersion = "\(modelId)_\(version)"
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(modelNameWithVersion)
    
    return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
  }
  
  public func saveLocalModel(_ model: ModelEntity, url: URL) {
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationURL = documentsDirectory.appendingPathComponent(model.versionedName)
    
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      
      try fileManager.copyItem(at: url, to: destinationURL)
    } catch {
      print("Error saving local model: \(error.localizedDescription)")
    }
  }
}
