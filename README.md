# Swoir

[![Swift 5](https://img.shields.io/badge/Swift-5-blue.svg)](https://developer.apple.com/swift/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/michaelelliot/swoir/actions/workflows/swift.yml/badge.svg)](https://github.com/michaelelliot/swoir/actions/workflows/swift.yml)

* [Overview](#overview)
* [Usage](#usage)
* [License](#license)

## <a name="overview">Overview</a>

This Swift package provides useful functionality for use with [Noir][noir] circuits.

[noir]: https://www.noir-lang.org

## <a name="usage">Usage</a>

```swift
let swoir = Swoir()
let circuitKey = "basic"
try swoir.addCircuit(key: circuitKey, manifest: "basic.json", bundle: Bundle.module)
let witnessInputs: [String: Any] = [
    "x": Int(1),
    "y": Int(5),
]
let initialWitness = try swoir.generateInitialWitness(key: circuitKey, inputs: witnessInputs)
```

See [Examples/SimpleUsage](./Examples/SimpleUsage/Sources/SimpleUsage/main.swift) for an example.

## <a name="license">License</a>

Swoir can be used, distributed and modified under [the MIT license](https://opensource.org/licenses/MIT).

MIT License

Copyright (c) 2023 Michael Elliot

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
