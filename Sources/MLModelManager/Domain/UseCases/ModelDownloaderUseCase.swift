//
//  ModelDownloaderUseCase.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelDownloaderUseCase {
  func downloadModel(model: ModelEntity, from url: URL) async throws -> URL
}
