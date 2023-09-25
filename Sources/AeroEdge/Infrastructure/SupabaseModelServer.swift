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
  
  public func fetchRemoteModelInfo(for modelName: String) async throws -> ModelEntity {
    let url = URL(string: "\(baseURL)/rest/v1/ml_models_metadata?name=eq.\(modelName)&select=*")!
    
    var request = URLRequest(url: url)
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue(apiKey, forHTTPHeaderField: "apiKey")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw ModelError.networkError
    }
    
    guard let apiResponse = try? JSONDecoder().decode([SupabaseResponse].self, from: data),
            let entityResponse = apiResponse.first,
          let fileUrl = URL(string: "\(baseURL)/storage/v1/object/public/public/\(entityResponse.file_path)")  else {
      throw ModelError.failedToLoadModel("Failed to parse response")
    }
    
    return ModelEntity(name: entityResponse.name, version: entityResponse.version, url: fileUrl)
  }
  
  struct SupabaseResponse: Decodable {
    let id: String
    let name: String
    let file_path: String
    let version: Int
  }
}
