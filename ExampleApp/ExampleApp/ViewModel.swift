//
//  ViewModel.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 20/09/2023.
//

import Foundation
import MLModelManager

class ViewModel: ObservableObject {
  private let mlModelManager: MLModelManager
  @Published var modelDescription: String?
  @Published var downloadProgress: Float?
  
  init(mlModelManager: MLModelManager) {
    self.mlModelManager = mlModelManager
  }
  
  func getYoloModel() async {
    await mlModelManager.getModel(modelName: MLModelInfo.yolo.name,
                                  bundledModelURL: MLModelInfo.yolo.bundledURL) { progress in
      print("Yolo Progress: \(progress)")
      self.downloadProgress = progress
    } completion: { result, isFinal in
      
      if isFinal {
        self.downloadProgress = nil
      }
      
      switch result {
      case .success(let model):
        print(model.modelDescription)
        self.modelDescription = model.description
      case .failure(let error):
        print(error.localizedDescription)
        self.modelDescription = error.localizedDescription
      }
    }
  }
}
