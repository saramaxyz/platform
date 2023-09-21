//
//  SupabaseModelServer.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 20/09/2023.
//

import Foundation

public class SupabaseModelServer: ModelServer {
  let baseURL: URL
  let apiKey: String
  
  public init(baseURL: URL, apiKey: String) {
    self.baseURL = baseURL
    self.apiKey = apiKey
  }
  
  public func fetchRemoteModelVersion(for modelName: String) async throws -> Int {
    let url = URL(string: "\(baseURL)/rest/v1/ml_models_metadata?name=eq.\(modelName)&select=*")!
    
    var request = URLRequest(url: url)
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue(apiKey, forHTTPHeaderField: "apiKey")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw ModelError.networkError
    }
    
    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
       let firstRecord = json.first,
       let version = firstRecord["version"] as? Int {
      return version
    } else {
      throw ModelError.failedToLoadModel("Failed to parse response")
    }
  }
  
  public func fetchRemoteModelFile(for modelName: String, version: Int) async throws -> URL {
    let fileURLString = "\(baseURL)/storage/v1/object/public/public/models/\(modelName)_\(version).mlmodel"
    guard let fileURL = URL(string: fileURLString) else {
      throw ModelError.failedToLoadModel("Invalid URL")
    }
    return fileURL
  }
}
