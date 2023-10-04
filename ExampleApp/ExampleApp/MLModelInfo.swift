//
//  MLModelInfo.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 22/09/2023.
//

import Foundation
import AeroEdge

struct MLModelInfo: Equatable {
  let name: String
  let modelType: ModelType
  let bundledURL: URL?
  
  static let yolo = MLModelInfo(name: "Yolo",
                                modelType: .mlModel,
                                bundledURL: Bundle.main.url(forResource: "YOLOv3Int8LUT", withExtension: ".mlmodelc"))
}
