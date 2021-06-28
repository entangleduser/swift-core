// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "Core",
	products: [
		.library(
			name: "Core",
			targets: [
				"Core",
				"Colors",
				"Storage",
				"Structures",
				"Swizzle",
				"UI"
			]
		)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-algorithms", from: "0.2.1")
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
			name: "Storage",
			dependencies: ["Core"]
		),
		.target(
			name: "Structures",
			dependencies: ["Core"]
		),
		.target(
			name: "Swizzle",
			dependencies: ["Core"]
		),
		.target(
			name: "UI",
			dependencies: ["Core"]
		),
		.testTarget(
			name: "CoreTests",
			dependencies: ["Core"]
		),
		.testTarget(
			name: "StorageTests",
			dependencies: ["Storage"]
		),
		.testTarget(
			name: "StructuresTests",
			dependencies: ["Structures"]
		)
	]
)
