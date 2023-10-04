//
//  ModelEntity.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public struct ModelEntity {
  public let name: String
  public let version: Int
  public let url: URL
  public var fileExtension: String = "mlmodel"
  
  public var versionedName: String {
    "\(name)_\(version)"
  }
  
  public var versionedNameWithExtension: String {
    "\(versionedName).\(fileExtension)"
  }
  
  public var versionedNameWithExtensionZipped: String {
    "\(versionedName).\(fileExtension).zip"
  }
}
