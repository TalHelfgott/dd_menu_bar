// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "DatadogMenuBar",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "DatadogMenuBar",
            targets: ["DatadogMenuBar"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "DatadogMenuBar",
            dependencies: [
            ]
        )
    ]
) 