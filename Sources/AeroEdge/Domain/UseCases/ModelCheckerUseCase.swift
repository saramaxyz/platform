//
//  ModelCheckerUseCase.swift
//  
//
//  Created by Egzon Arifi on 19/09/2023.
//

import Foundation

protocol ModelCheckerUseCase {
  func checkLocalModelVersion(modelName: String,
                              remoteVersion: Int,
                              fileExtension: String) -> Bool
}
