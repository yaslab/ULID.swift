# ULID.swift

[![Build Status](https://travis-ci.org/yaslab/ULID.swift.svg?branch=master)](https://travis-ci.org/yaslab/ULID.swift)
[![codecov](https://codecov.io/gh/yaslab/ULID.swift/branch/master/graph/badge.svg)](https://codecov.io/gh/yaslab/ULID.swift)

Implementation of [ULID](https://github.com/ulid/spec/blob/master/README.md) in Swift.

## Usage

### Generate ULID

```swift
// Generate ULID using current time
let ulid = ULID()

// Get ULID string
let string: String = ulid.ulidString
// Get ULID binary data
let data: Data = ulid.ulidData
```

### Parse ULID

```swift
// Parse ULID string
let ulid = ULID(ulidString: "01D0YHEWR9WMPY4NNTPK1MR1TQ")!

// Get Timestamp as Date
let timestamp: Date = ulid.timestamp
```

## Installation

### CocoaPods

```
pod 'ULID.swift', '~> 1.0.0'
```

### Carthage

```
github "yaslab/ULID.swift" ~> 1.0.0
```

### Swift Package Manager

```
.package(url: "https://github.com/yaslab/ULID.swift.git", .upToNextMinor(from: "1.0.0"))
```

## License

ULID.swift is released under the MIT license. See the [LICENSE](https://github.com/yaslab/ULID.swift/blob/master/LICENSE) file for more info.
