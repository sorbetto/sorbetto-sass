import PackageDescription

let package = Package(
    name: "SorbettoSass",
    dependencies: [
        .Package(url: "../Sorbetto", majorVersion: 0),
        .Package(url: "https://github.com/sorbetto/swift-sass.git", Version(1, 0, 0)),
    ]
)
