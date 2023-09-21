//
//  ContentView.swift
//  ExampleApp
//
//  Created by Egzon Arifi on 20/09/2023.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject private var viewModel: ViewModel = .init()
  
    var body: some View {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Hello, world!")
        if let description = viewModel.modelDescription {
          Text(description)
        }
        if let progress = viewModel.downloadProgress {
          ProgressView("Downloading", value: progress, total: 1.0)
        } else {
          Text("The Model is ready!").fontWeight(.bold)
        }
      }
        .padding()
        .task {
          await viewModel.getYoloModel()
        }
    }
}

#Preview {
    ContentView()
}
