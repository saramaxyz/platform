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
  
  public func getLocalModelVersion(for modelName: String,
                                   fileExtension: String = "mlmodel") -> Int? {
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
      let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
      
      // Filtering files which contain the modelName in their name
      let modelFiles = files.filter { $0.lastPathComponent.contains("\(modelName)_") }
      
      // Extracting version numbers and finding the highest version
      let versions = modelFiles.compactMap { url -> Int? in
        let fileName = url.lastPathComponent
        guard let startRange = fileName.range(of: "\(modelName)_"),
              let endRange = fileName.range(of: ".\(fileExtension)") else { return nil }
        
        // Extract the version number using the range between the modelName_ and .mlmodel
        let versionString = fileName[startRange.upperBound..<endRange.lowerBound]
        
        return Int(versionString)
      }
      
      return versions.max()
      
    } catch {
      print("Error while listing files: \(error.localizedDescription)")
      return nil
    }
  }

  public func getLocalModelURL(for modelName: String, version: Int, fileExtension: String) -> URL? {
    let modelNameWithVersion = "\(modelName)_\(version).\(fileExtension)"
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(modelNameWithVersion)
    
    return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
  }
  
  public func saveLocalModel(_ model: ModelEntity, url: URL) {
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationURL = documentsDirectory.appendingPathComponent(model.versionedNameWithExtensionZipped)
    
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      
      try fileManager.copyItem(at: url, to: destinationURL)
    } catch {
      print("Error saving local model: \(error.localizedDescription)")
    }
  }
  
  public func deleteOldVersions(of model: ModelEntity) {
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
      // Getting a list of all files in the directory
      let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
      
      // Filtering files which contain the modelName in their name and are older versions
      let olderModelFiles = files.filter {
        $0.lastPathComponent.contains(model.name) && !$0.lastPathComponent.contains(model.versionedName)
      }
      
      // Removing older version files
      for fileURL in olderModelFiles {
        try fileManager.removeItem(at: fileURL)
      }
    } catch {
      print("Error while deleting older versions of model: \(error.localizedDescription)")
    }
  }
}
