import Foundation
import Swoir

let swoir = Swoir()

let circuitKey = "swoir_example"
try swoir.addCircuit(key: circuitKey, manifest: "swoir_example.json", bundle: Bundle.module)

let witnessInputs: [String: Any] = [
    "a": "Hello123".data(using: .utf8)!,
    "b": "Hello123".data(using: .utf8)!,
    "c": UInt8(0x01),
    "d": Int(8),
    "e": Int(16),
    "x": Int(1),
    "y": Int(2),
]
let initialWitness = try swoir.generateInitialWitness(key: circuitKey, inputs: witnessInputs)

print("Initial witness: \(initialWitness)")
