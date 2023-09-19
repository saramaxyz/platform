//
//  ModelCompilerUseCase.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation
import CoreML

public protocol ModelCompilerUseCase {
  func compileModel(model: ModelEntity, from localURL: URL) async throws -> MLModel
}
