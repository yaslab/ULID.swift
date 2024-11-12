# ULID.swift

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyaslab%2FULID.swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/yaslab/ULID.swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyaslab%2FULID.swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/yaslab/ULID.swift)

Implementation of [ULID](https://github.com/ulid/spec/blob/master/README.md) in Swift.

## Usage

### Generate ULID

```swift
import ULID

// Generate ULID using current time
let ulid = ULID()

// Get ULID string
let string: String = ulid.ulidString
// Get ULID binary data
let data: Data = ulid.ulidData
```

### Parse ULID

```swift
import ULID

// Parse ULID string
let ulid = ULID(ulidString: "01D0YHEWR9WMPY4NNTPK1MR1TQ")!

// Get Timestamp as Date
let timestamp: Date = ulid.timestamp
```

### Convert between ULID and UUID

Both ULID and UUID are 128 bit data, so you can convert strings to each other.

#### From ULID to UUID

```swift
import Foundation
import ULID

let ulid = ULID(ulidString: "01D132CXJVYQ7091KZPZR5WH1X")!
let uuid = UUID(uuid: ulid.ulid)
print(uuid.uuidString) // 01684626-765B-F5CE-0486-7FB7F05E443D
```

#### From UUID to ULID

```swift
import Foundation
import ULID

let uuid = UUID(uuidString: "01684626-765B-F5CE-0486-7FB7F05E443D")!
let ulid = ULID(ulid: uuid.uuid)
print(ulid.ulidString) // 01D132CXJVYQ7091KZPZR5WH1X
```

### Monotonically Sorted ULIDs

To generate ULIDs that are guaranteed to be monotonically sorted:

```swift
import ULID

// Create a monotonic factory
let factory = ULID.MonotonicFactory()

// Generate ULIDs that are guaranteed to sort correctly
let ulid1 = factory.create()
let ulid2 = factory.create()
let ulid3 = factory.create()

// These will always be true
assert(ulid1 < ulid2)
assert(ulid2 < ulid3)
```

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`. For example:

```swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        // Add `ULID.swift` package here.
        .package(url: "https://github.com/yaslab/ULID.swift.git", from: "1.3.1")
    ],
    targets: [
        .executableTarget(
            name: "MyCommand",
            dependencies: [
                // Then add it to your module's dependencies.
                .product(name: "ULID", package: "ULID.swift")
            ]
        )
    ]
)
```

### CocoaPods

```
pod 'ULID.swift', '~> 1.3.1'
```

## License

ULID.swift is released under the MIT license. See the [LICENSE](https://github.com/yaslab/ULID.swift/blob/master/LICENSE) file for more info.
