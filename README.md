# AeroEdge SDK for iOS

## Overview

`AeroEdge` is an iOS SDK designed to streamline the process of fetching, managing, and compiling machine learning models. It offers seamless integration with your iOS apps, ensuring you can efficiently check local models, download new versions, and compile them for use.

Features:

- **Local Model Checking**: Quickly determine if the local version of a model matches the latest one.
- **Automatic Downloads**: If a newer version of a model exists, the SDK can fetch it for you.
- **Model Compilation**: Compile downloaded models, readying them for integration with your app.
- **Model Storage**: Models are stored locally and can be managed to ensure only the latest version is kept.
- **Seamless Integration**: Designed with Swift's modern features in mind, it integrates well with other iOS components.
- **Background support**: Ensuring downloads continue even if the app goes into the background.

### Installation Steps:

#### Prerequisites:

- iOS 16.0 or later.
- Xcode 13.0 or later.

#### Swift Package Manager:

Add the following lines to your `Package.swift` file:

```swift
let package = Package(
    ...
    dependencies: [
        ...
        .package(name: "AeroEdge", url: "https://github.com/saramaxyz/AeroEdge.git", branch: "main"), // Add the package
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: ["AeroEdge"] // Add as a dependency
        )
    ]
)
```

Or in Xcode, File > Add Package Dependency and add the url:  

```url
https://github.com/saramaxyz/AeroEdge.git
```

## Usage

### Initialization:

To start using `AeroEdge`, you'll first need to initialize it using your `apiKey`. Here's how you can do it:

```swift
import AeroEdge

let apiKey = "YOUR_API_KEY_HERE"
let aeroEdge = AeroEdge.make(apiKey: apiKey)
```

### Fetching a Model:

After initializing the manager, fetching a model becomes a breeze.

```swift
aeroEdge.getModel(modelName: "YourModelName", bundledModelURL: nil, progress: { progress in
    print("Download Progress: \(progress)")
}, completion: { result, isFinal in
    switch result {
    case .success(let model):
        // Use the fetched model
        print(model.modelDescription)
    case .failure(let error):
        // Handle the error
        print(error.localizedDescription)
    }
})
```

Replace `"YourModelName"` with the name of the model you wish to fetch.

### Background Support

`AeroEdge` SDK supports background downloads, ensuring that the download of ML models continues even if your app goes to the background. Here's how to set it up:

#### Enable Background Modes Capability:

1. Open your project in Xcode.
2. Select the app target and navigate to the "Signing & Capabilities" tab.
3. Click the "+" button and add the "Background Modes" capability.
4. Check the "Background fetch" and "Background processing" options.

#### AppDelegate Setup:

If you're using `UIKit`, ensure the `AppDelegate` integrates with the `AeroEdge`:

```swift
import UIKit
import AeroEdge

class AppDelegate: NSObject, UIApplicationDelegate {
  let aeroEdge: AeroEdge = .make(apiKey: "your_token_here")

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }

  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    if identifier == AeroEdge.backgroundIdentifier {
      AeroEdge.backgroundSessionCompletionHandler = completionHandler
    }
  }
}
```

#### Integration with SwiftUI:

If you're using SwiftUI, you can use the `AppDelegate` as follows:

```swift
@main
struct ExampleAppApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: ViewModel(AeroEdge: appDelegate.AeroEdge))
    }
  }
}
```

By integrating these steps, you ensure that the `AeroEdge` handles model downloads efficiently, even in the background.

## Contributing

If you find any bugs or have a feature request, please open an issue on GitHub. Contributions, issues, and feature requests are welcome!

## Support

For major concerns or assistance, you can reach out to the team directly @[AeroEdge](https://aeroedgeai.com)

## License

This SDK is under a specific license [MIT Licence](https://github.com/saramaxyz/AeroEdge/blob/develop/LICENSE). All rights reserved.
