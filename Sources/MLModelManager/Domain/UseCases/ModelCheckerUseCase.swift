//
//  ModelCheckerUseCase.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

public protocol ModelCheckerUseCase {
  func checkLocalModelVersion(model: ModelEntity) -> Bool
}
