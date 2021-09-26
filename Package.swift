// swift-tools-version:5.3

import PackageDescription

let package = Package(
        name: "RemasteredCurrency",
        products: [
            .library(
                    name: "RemasteredCurrency",
                    targets: ["RemasteredCurrency"]
            )
        ],
        dependencies: [
            .package(url: "https://github.com/kanekireal/RemasteredJson.git", from: "1.1.0")
        ],
        targets: [
            .target(
                    name: "RemasteredCurrency",
                    dependencies: ["RemasteredJson"],
                    resources: [
                        .process("Resources/remastered_currencies.json")
                    ]
            ),
            .testTarget(
                    name: "RemasteredCurrencyTests",
                    dependencies: ["RemasteredCurrency"])
        ]
)
