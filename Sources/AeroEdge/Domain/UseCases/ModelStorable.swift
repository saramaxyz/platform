//
//  ModelStorable.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelStorable {
  func getLocalModelVersion(for modelName: String) -> Int?
  func getLocalModelURL(for modelName: String, version: Int) -> URL?
  func saveLocalModel(_ model: ModelEntity, url: URL)
  func deleteOldVersions(of model: ModelEntity)
}
