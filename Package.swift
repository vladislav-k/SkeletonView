// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SkeletonView",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "SkeletonView",
            targets: ["SkeletonView"]
        )
    ],
    targets: [
        .target(
            name: "SkeletonView",
            path: "SkeletonViewCore/Sources",
            exclude: ["Supporting Files/Info.plist"],
            resources: [.copy("Supporting Files/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "SkeletonViewTests",
            dependencies: ["SkeletonView"],
            path: "SkeletonViewCore/Tests",
            exclude: ["Supporting Files"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
