//
//  ModelServer.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelServer {
  func fetchRemoteModelInfo(for modelName: String) async throws -> ModelEntity
}
