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
  
  init(mlModelManager: MLModelManager = .makeWithSupabase(baseURL: Constants.Supabase.url, apiKey: Constants.Supabase.apiKey)) {
    self.mlModelManager = mlModelManager
  }
  
  func getYoloModel() async {
    await mlModelManager.getModel(modelName: "Yolo",
                                  bundledModelURL: Bundle.main.url(forResource: "YOLOv3Int8LUT", withExtension: ".mlmodelc")) { progress in
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
