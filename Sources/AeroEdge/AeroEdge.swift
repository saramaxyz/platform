//
//  AeroEdge.swift
//
//
//  Created by Egzon Arifi on 19/09/2023.
//

import CoreML
import ZIPFoundation

public class AeroEdge: NSObject {
  public static let backgroundIdentifier = "com.app.backgroundModelDownload"
  private let modelChecker: ModelCheckerUseCase
  private let modelCompiler: ModelCompilerUseCase
  internal var modelDownloader: ModelDownloaderUseCase
  private let localModelStore: ModelStorable
  private let modelServer: ModelServer
  public var backgroundSessionCompletionHandler: (() -> Void)?
  private var downloadProgressClosures: [String: (Float) -> Void] = [:]
  
  init(modelChecker: ModelCheckerUseCase,
       modelCompiler: ModelCompilerUseCase,
       modelDownloader: ModelDownloaderUseCase,
       localModelStore: ModelStorable,
       modelServer: ModelServer) {
    self.modelChecker = modelChecker
    self.modelCompiler = modelCompiler
    self.modelDownloader = modelDownloader
    self.localModelStore = localModelStore
    self.modelServer = modelServer
  }
  
  public func getModel(
    modelName: String,
    modelType: ModelType = .mlModel,
    bundledModelURL: URL?,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<MLModel, Error>, Bool) -> Void
  ) async {
    do {
      // Step 1: Fetch remote model version
      let modelInfo = try await modelServer.fetchRemoteModelInfo(for: modelName)
      let remoteVersion = modelInfo.version
      
      // Step 2: Check local model version
      if modelChecker.checkLocalModelVersion(modelName: modelName,
                                             remoteVersion: remoteVersion,
                                             fileExtension: modelType.rawValue),
         let localVersion = self.localModelStore.getLocalModelVersion(for: modelName,
                                                                      fileExtension: modelType.rawValue) {
        // Load local model and return
        let localModel = try await self.loadLocalModel(modelName: modelName, version: localVersion, fileExtension: modelType.rawValue)
        completion(.success(localModel), true) // true indicates that this is the final model and no newer version is available
      } else {
        // Step 3: If there's a local version, return it first
        if let localOrBundledModel = try? await loadLocalOrBundledModel(modelName: modelName, bundledModelURL: bundledModelURL) {
          completion(.success(localOrBundledModel), false) // false indicates that a newer version is being downloaded
        }
        
        // Now download the newer version from the server
        if let progressClosure = progress {
          self.downloadProgressClosures["\(modelName)_\(remoteVersion).\(modelType.rawValue)"] = progressClosure
        }
        do {
          let newModel = try await self.downloadAndLoadModel(modelName: modelName,
                                                             fileExtension: modelType.rawValue,
                                                             remoteVersion: remoteVersion,
                                                             remoteModelURL: modelInfo.url,
                                                             bundledModelURL: bundledModelURL)
          completion(.success(newModel), true) // true indicates that this is the final model
        } catch {
          completion(.failure(error), true) // true indicates that this is the final callback
        }
      }
    } catch {
      // Handle error - try loading local or bundled version if available
      do {
        let fallbackModel = try await loadLocalOrBundledModel(modelName: modelName,
                                                              bundledModelURL: bundledModelURL,
                                                              fileExtension: modelType.rawValue)
        completion(.success(fallbackModel), true) // true indicates that this is the final model
      } catch {
        completion(.failure(error), true) // true indicates that this is the final callback
      }
    }
  }
}

private extension AeroEdge {
  func loadLocalModel(modelName: String, version: Int, fileExtension: String = "mlmodel") async throws -> MLModel {
    // Get the URL of the local model using the `ModelLocalStore` instance
    guard let modelURL = localModelStore.getLocalModelURL(for: modelName,
                                                          version: version,
                                                          fileExtension: fileExtension) else {
      throw ModelError.modelNotFound
    }
    
    // Try to load the MLModel from the obtained URL
    do {
      let modelEntity = ModelEntity(name: modelName,
                                    version: version,
                                    url: modelURL,
                                    fileExtension: fileExtension)
      let model = try await modelCompiler.compileModel(model: modelEntity, from: modelURL)
      return model
    } catch {
      // If there's an error in loading the model, throw a specific error
      throw ModelError.failedToLoadModel(error.localizedDescription)
    }
  }
  
  func downloadAndLoadModel(modelName: String,
                            fileExtension: String = "mlmodel",
                            remoteVersion: Int,
                            remoteModelURL: URL,
                            bundledModelURL: URL?) async throws -> MLModel {
    do {
      // Create a ModelEntity instance to represent the model
      let modelEntity = ModelEntity(name: modelName,
                                    version: remoteVersion,
                                    url: remoteModelURL,
                                    fileExtension: fileExtension)
      
      // Download the model using the ModelDownloader
      let downloadURL = try await modelDownloader.downloadModelAsync(modelEntity)
      
      // TODO: HANDLE UNZIP HERE FIRST
      try FileManager.default.unzipItem(at: downloadURL, to: downloadURL.deletingLastPathComponent())
      
      // TODO: Delete zip file
      try FileManager.default.removeItem(at: downloadURL)
      
      // Load the newly downloaded model into memory
      let mlModel = try await modelCompiler.compileModel(model: modelEntity,
                                                         from: downloadURL.deletingPathExtension())
      
      return mlModel
    } catch {
      // Handle various error cases, e.g., trying to load a bundled model if the download failed
      if let bundledModelURL = bundledModelURL {
        let bundledModel = try MLModel(contentsOf: bundledModelURL)
        return bundledModel
      } else {
        // If no bundled model is available, rethrow the error to be handled upstream
        throw error
      }
    }
  }
  
  func loadLocalOrBundledModel(modelName: String,
                               bundledModelURL: URL?,
                               fileExtension: String = "mlmodel") async throws -> MLModel {
    if let latestLocalVersion = self.localModelStore.getLocalModelVersion(for: modelName,
                                                                          fileExtension: fileExtension) {
      // If a local version is available, load it
      return try await self.loadLocalModel(modelName: modelName, version: latestLocalVersion)
    } else if let bundledModelURL = bundledModelURL {
      // If no local version is available, try loading the bundled version
      let bundledModel = try MLModel(contentsOf: bundledModelURL)
      return bundledModel
    } else {
      // If neither a local version nor a bundled version is available, throw an error
      throw ModelError.fileNotFound
    }
  }
}

extension AeroEdge: ModelDownloadDelegate {
  public func modelDownloadProgress(forModel modelName: String, progress: Float) {
    downloadProgressClosures[modelName]?(progress)
  }
  
  public func handleAllTasksCompleted() {
    backgroundSessionCompletionHandler?()
    backgroundSessionCompletionHandler = nil
  }
}
