//
//  MLModelInfo.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 22/09/2023.
//

import Foundation

struct MLModelInfo: Equatable {
  let name: String
  let bundledURL: URL?
  
  static let yolo = MLModelInfo(name: "Yolo", bundledURL: Bundle.main.url(forResource: "YOLOv3Int8LUT", withExtension: ".mlmodelc"))
}
