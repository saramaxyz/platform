//
//  ModelStorable.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelStorable {
  func getLocalModelVersion(for modelId: String) -> Int?
  func getLocalModelURL(for modelId: String, version: Int) -> URL?
  func saveLocalModel(_ model: ModelEntity, url: URL)
}
