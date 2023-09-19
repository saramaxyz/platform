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
  
  public init(modelStore: ModelLocalStore) {
    self.modelStore = modelStore
    super.init()
    
    let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "com.app.backgroundModelDownload")
    self.backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: nil)
  }
  
  public func downloadModel(_ model: ModelEntity, completion: @escaping (Result<URL, Error>) -> Void) {
    let downloadTask = backgroundSession.downloadTask(with: model.url)
    downloadCompletionHandlers[downloadTask] = completion
    downloadTask.resume()
  }
  
  public func addModel(_ model: ModelEntity) {
    modelDataSource[model.id] = model
  }
  
  public func addModels(_ models: [ModelEntity]) {
    models.forEach { addModel($0) }
  }
}

extension ModelDownloader: URLSessionDownloadDelegate {
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    // Handle download completion: move file to permanent location, save in local store, and call completion handler
    guard let modelId = downloadTask.originalRequest?.url?.lastPathComponent,
          let model = getModel(by: modelId),
          let completionHandler = downloadCompletionHandlers[downloadTask] else {
      return
    }
    
    do {
      let destinationURL = modelStore.getLocalModelURL(for: model.id, version: model.version) ?? createDestinationURL(for: model)
      try FileManager.default.moveItem(at: location, to: destinationURL)
      
      modelStore.saveLocalModel(model, url: destinationURL)
      
      // Delete older versions
      deleteOldVersions(of: model)
      
      completionHandler(.success(destinationURL))
    } catch {
      completionHandler(.failure(error))
    }
  }
  
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    // Update downloadProgress dictionary to track progress
    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    downloadProgress[downloadTask] = progress
    delegate?.modelDownloadDidProgress(self, taskId: downloadTask.taskIdentifier, progress: progress)
  }
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    // Handle errors
    if let error = error, let completionHandler = downloadCompletionHandlers[task] {
      completionHandler(.failure(error))
    }
  }
}

private extension ModelDownloader {
  func getModel(by id: String) -> ModelEntity? {
    modelDataSource[id]
  }
  
  func createDestinationURL(for model: ModelEntity) -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsDirectory.appendingPathComponent(model.versionedName)
  }
  
  func deleteOldVersions(of model: ModelEntity) {
    modelStore.deleteOldVersions(of: model)
  }
}
