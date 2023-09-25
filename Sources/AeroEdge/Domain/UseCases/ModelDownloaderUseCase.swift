//
//  ModelDownloaderUseCase.swift
//
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelDownloaderUseCase {
  var delegate: ModelDownloadDelegate? { get set }
  
  func downloadModel(_ model: ModelEntity, completion: @escaping (Result<URL, Error>) -> Void)
  func addModel(_ model: ModelEntity)
  func addModels(_ models: [ModelEntity])
}

public extension ModelDownloaderUseCase {
  func downloadModelAsync(_ model: ModelEntity) async throws -> URL {
    addModel(model)
    return try await withCheckedThrowingContinuation { continuation in
      self.downloadModel(model) { result in
        switch result {
        case .success(let url):
          continuation.resume(returning: url)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

public protocol ModelDownloadDelegate: AnyObject {
  func modelDownloadProgress(forModel modelName: String, progress: Float)
  func handleAllTasksCompleted()
}
