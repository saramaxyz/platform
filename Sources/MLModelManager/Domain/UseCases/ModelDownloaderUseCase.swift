//
//  ModelDownloaderUseCase.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelDownloaderUseCase {
  func downloadModel(_ model: ModelEntity, completion: @escaping (Result<URL, Error>) -> Void)
  func addModel(_ model: ModelEntity)
  func addModels(_ models: [ModelEntity])
}

public protocol ModelDownloadDelegate: AnyObject {
  func modelDownloadDidProgress(_ downloader: ModelDownloader, taskId: Int, progress: Float)
}
