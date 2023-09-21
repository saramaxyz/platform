//
//  ModelError.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public enum ModelError: Error {
  case invalidURL
  case fileNotFound
  case networkError
  case fileWriteError
  case downloadError(String)
  case compilationError(String)
  case failedToLoadModel(String)
  case modelNotFound
  
  var localizedDescription: String {
    switch self {
    case .invalidURL:
      return "The URL provided is invalid."
    case .fileNotFound:
      return "The file could not be found on the device."
    case .downloadError(let message):
      return "An error occurred during the download: \(message)"
    case .compilationError(let message):
      return "An error occurred during the compilation: \(message)"
    case .networkError:
      return "An error occurred during the network request"
    case .fileWriteError:
      return "An error occurred during the file writing"
    case .failedToLoadModel(let message):
      return "An error occurred while loading the model: \(message)"
    case .modelNotFound:
      return "The model not found!"
    }
  }
}
