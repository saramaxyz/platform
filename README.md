# MLModelManager SDK for iOS

## Overview

`MLModelManager` is an iOS SDK designed to streamline the process of fetching, managing, and compiling machine learning models. It offers seamless integration with your iOS apps, ensuring you can efficiently check local models, download new versions, and compile them for use.

Features:

- **Local Model Checking**: Quickly determine if the local version of a model matches the latest one.
- **Automatic Downloads**: If a newer version of a model exists, the SDK can fetch it for you.
- **Model Compilation**: Compile downloaded models, readying them for integration with your app.
- **Model Storage**: Models are stored locally and can be managed to ensure only the latest version is kept.
- **Seamless Integration**: Designed with Swift's modern features in mind, it integrates well with other iOS components.

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
        .package(name: "MLModelManager", url: "https://github.com/saramaxyz/MLModelManager.git", branch: "main"), // Add the package
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: ["MLModelManager"] // Add as a dependency
        )
    ]
)
```

Or in Xcode, File > Add Package Dependency and add the url:  

```url
https://github.com/saramaxyz/MLModelManager.git
```

## Usage

### Initialization:

To start using `MLModelManager`, you'll first need to initialize it using your `apiKey`. Here's how you can do it:

```swift
import MLModelManager

let apiKey = "YOUR_API_KEY_HERE"
let modelManager = MLModelManager.make(apiKey: apiKey)
```

### Fetching a Model:

After initializing the manager, fetching a model becomes a breeze.

```swift
modelManager.getModel(modelName: "YourModelName", bundledModelURL: nil, progress: { progress in
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

## Contributing

If you find any bugs or have a feature request, please open an issue on GitHub. Contributions, issues, and feature requests are welcome!

## Support

For major concerns or assistance, you can reach out to the team directly @[AeroEdge](https://aeroedgeai.com)

## License

This SDK is under a specific license [MIT Licence](https://github.com/saramaxyz/MLModelManager/blob/develop/LICENSE). All rights reserved.
