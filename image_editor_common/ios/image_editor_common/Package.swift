// swift-tools-version: 5.9

import PackageDescription

let packageName = "image_editor_common"

let package = Package(
  name: packageName,
  platforms: [
    .iOS("9.0"),
  ],
  products: [
    .library(name: "image-editor-common", targets: [packageName]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: packageName,
      dependencies: [],
      cSettings: [
        .headerSearchPath("include/\(packageName)"),
      ]
    ),
  ]
)
