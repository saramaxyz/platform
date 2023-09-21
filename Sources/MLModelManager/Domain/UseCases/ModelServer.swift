//
//  ModelServer.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelServer {
  func fetchRemoteModelVersion(for modelName: String) async throws -> Int
  func fetchRemoteModelFile(for modelName: String, version: Int) async throws -> URL
}
