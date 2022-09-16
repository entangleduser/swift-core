// swift-tools-version: 5.6
import PackageDescription

let package = Package(
 name: "Core",
 platforms: [.macOS(.v11), .iOS(.v15)],
 products: [
  .library(name: "Core", targets: ["Core"]),
  .library(name: "Colors", targets: ["Colors"]),
  .library(name: "CoreStorage", targets: ["CoreStorage"]),
  .library(name: "Structures", targets: ["Structures"]),
  .library(name: "Swizzle", targets: ["Swizzle"]),
  .library(name: "Reflection", targets: ["Reflection"]),
  .library(name: "CoreViews", targets: ["CoreViews"])
 ],
 dependencies: [
  .package(url: "https://github.com/apple/swift-collections", branch: "main"),
  .package(url: "https://github.com/apple/swift-algorithms", branch: "main"),
  .package(url: "https://github.com/siteline/SwiftUI-Introspect", branch: "master")
 ],
 targets: [
  .target(
   name: "Core",
   dependencies: [
    .product(name: "Algorithms", package: "swift-algorithms")
   ]
  ),
  .target(
   name: "Colors",
   dependencies: ["Core"]
  ),
  .target(
   name: "CoreStorage",
   dependencies: ["Core", "Reflection"]
  ),
  .target(
   name: "Structures",
   dependencies: [
    "Core",
    .product(name: "Collections", package: "swift-collections")
   ]
  ),
  .target(
   name: "Swizzle",
   dependencies: ["Core"]
  ),
  .target(
   name: "Reflection",
   dependencies: ["Core"]
  ),
  .target(
   name: "CoreViews",
   dependencies: [
    "Core",
    "Structures",
    "Colors",
    "CoreStorage",
    .product(name: "Introspect", package: "swiftui-introspect")
   ],
   resources: [
    .process("Resources")
   ]
  ),
  .testTarget(
   name: "CoreTests",
   dependencies: ["Core"]
  ),
  .testTarget(
   name: "CoreStorageTests",
   dependencies: ["CoreStorage"]
  ),
  .testTarget(
   name: "StructuresTests",
   dependencies: ["Structures"]
  )
 ]
)
