//
//  AeroEdgeModelServer.swift
//  
//
//  Created by Egzon Arifi on 22/09/2023.
//

import Foundation

public class AeroEdgeModelServer: ModelServer {
  let baseURL: URL = URL(string: "https://aeroedge-backend.fly.dev")!
  let apiKey: String
  
  public init(apiKey: String) {
    self.apiKey = apiKey
  }
  
  public func fetchRemoteModelInfo(for modelName: String) async throws -> ModelEntity {
    let url = URL(string: "\(baseURL)/models/\(modelName)/latest")!
    
    var request = URLRequest(url: url)
    request.addValue(apiKey, forHTTPHeaderField: "apiKey")
    request.addValue("application/json", forHTTPHeaderField: "accept")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw ModelError.networkError
    }
    
    guard let apiResponse = try? JSONDecoder().decode(ModelInfo.self, from: data) else {
      throw ModelError.failedToLoadModel("Failed to parse response")
    }
    
    return ModelEntity(name: apiResponse.name, version: apiResponse.version, url: apiResponse.signed_url)
  }
  
  struct ModelInfo: Decodable {
    let name: String
    let signed_url: URL
    let version: Int
  }
}
