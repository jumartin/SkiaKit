// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import Foundation
import PackageDescription

let dir = URL(fileURLWithPath: #file).deletingLastPathComponent().path

let package = Package(
    name: "SkiaKit",
    products: [
        .library(name: "SkiaKit", targets: ["SkiaKit"]),
		.library(name: "CSkiaSharp", targets: ["CSkiaSharp"])
    ],
    targets: [
	.testTarget (
		name: "SkiaKitTests",
		dependencies: ["SkiaKit"]
	),
    .target (
		name: "SkiaKit", 
		dependencies: ["CSkiaSharp"],
		cSettings: [
		.headerSearchPath("include")
		]
	),
	.target (
		name: "CSkiaSharp",
		cSettings: [
		.headerSearchPath("include"),
		],
		linkerSettings: [
			.unsafeFlags(["-L" + dir])
		]
	)
    ]
)

