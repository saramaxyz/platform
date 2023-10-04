//
//  ModelDownloader.swift
//
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public class ModelDownloader: NSObject, ModelDownloaderUseCase {
  private var downloadProgress: [URLSessionTask: Float] = [:]
  private var downloadCompletionHandlers: [URLSessionTask: (Result<URL, Error>) -> Void] = [:]
  private var backgroundSession: URLSession!
  private let modelStore: ModelLocalStore
  private var modelDataSource: [String: ModelEntity] = [:]
  public weak var delegate: ModelDownloadDelegate?
  public var progressUpdate: ((Float) -> Void)?
  
  public init(modelStore: ModelLocalStore) {
    self.modelStore = modelStore
    super.init()
    
    let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: AeroEdge.backgroundIdentifier)
    self.backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: nil)
  }
  
  public func downloadModel(_ model: ModelEntity, completion: @escaping (Result<URL, Error>) -> Void) {
    let downloadTask = backgroundSession.downloadTask(with: model.url)
    downloadCompletionHandlers[downloadTask] = completion
    downloadTask.resume()
  }
  
  public func addModel(_ model: ModelEntity) {
    modelDataSource[model.versionedName] = model
  }
  
  public func addModels(_ models: [ModelEntity]) {
    models.forEach { addModel($0) }
  }
}

extension ModelDownloader: URLSessionDownloadDelegate {
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let modelName = downloadTask.originalRequest?.url?.lastPathComponent,
          let model = getModel(by: modelName),
          let completionHandler = downloadCompletionHandlers[downloadTask] else {
      return
    }
    
    do {
      let destinationURL = modelStore.getLocalModelURL(for: model.name,
                                                       version: model.version,
                                                       fileExtension: model.fileExtension) ?? createDestinationURL(for: model)
      
      // Check if directory exists, if not create it
      let directoryURL = destinationURL.deletingLastPathComponent()
      if !FileManager.default.fileExists(atPath: directoryURL.path) {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
      }
      
      // Delete older versions
      deleteOldVersions(of: model)
      
      // Move file to destination
      if FileManager.default.fileExists(atPath: destinationURL.path) {
        try FileManager.default.removeItem(at: destinationURL)
      }
      try FileManager.default.moveItem(at: location, to: destinationURL)
      
      completionHandler(.success(destinationURL))
    } catch {
      print("Error detail: \(error.localizedDescription)")
      completionHandler(.failure(error))
    }
    
    handleAllTasksCompletedIfNeeded(session)
  }
  
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    // Update downloadProgress dictionary to track progress
    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    downloadProgress[downloadTask] = progress
    
    guard let modelName = downloadTask.originalRequest?.url?.lastPathComponent else {
      return
    }
    delegate?.modelDownloadProgress(forModel: modelName, progress: progress)
  }
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    // Handle errors
    if let error = error, let completionHandler = downloadCompletionHandlers[task] {
      completionHandler(.failure(error))
    }
    
    handleAllTasksCompletedIfNeeded(session)
  }
}

private extension ModelDownloader {
  func handleAllTasksCompletedIfNeeded(_ session: URLSession) {
    session.getAllTasks { tasks in
      if tasks.isEmpty {
        self.delegate?.handleAllTasksCompleted()
      }
    }
  }
  
  func getModel(by id: String) -> ModelEntity? {
    guard let name = id.components(separatedBy: ".").first else { return nil }
    return modelDataSource[name]
  }
  
  func createDestinationURL(for model: ModelEntity) -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsDirectory.appendingPathComponent(model.versionedNameWithExtensionZipped)
  }
  
  func deleteOldVersions(of model: ModelEntity) {
    modelStore.deleteOldVersions(of: model)
  }
}
