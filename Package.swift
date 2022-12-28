// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "openGL",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable (
            name: "openGL",
            targets: ["openGL"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
         .package(name: "SGLMath", url: "https://github.com/SwiftGL/Math.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "openGL",
            dependencies: [ "CSDL2", "CGL", "SGLMath" ]),
        // TODO: Make sure this works when libs are not installed yet    
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
                .apt(["libsdl2-dev"])
            ]),
        .systemLibrary(
            name: "CGL", 
            pkgConfig: "glew",
            providers: [
                .brew(["glew"]),
                .apt(["libglew-dev"])
            ]),
        .testTarget(
            name: "openGLTests",
            dependencies: ["openGL"]),
    ]
)