//
//  ViewModel.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 20/09/2023.
//

import Foundation
import AeroEdge

class ViewModel: ObservableObject {
  private let aeroEdge: AeroEdge
  @Published var modelDescription: String?
  @Published var downloadProgress: Float?
  
  init(aeroEdge: AeroEdge) {
    self.aeroEdge = aeroEdge
  }
  
  func getYoloModel() async {
    await aeroEdge.getModel(modelName: MLModelInfo.yolo.name,
                            fileExtension: MLModelInfo.yolo.modelType.rawValue,
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
        DispatchQueue.main.async {
          self.modelDescription = model.description
        }
      case .failure(let error):
        print(error.localizedDescription)
        DispatchQueue.main.async {
          self.modelDescription = error.localizedDescription
        }
      }
    }
  }
}
