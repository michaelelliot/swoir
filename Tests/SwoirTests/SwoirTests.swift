import XCTest
@testable import Swoir

final class SwoirTests: XCTestCase {
    func testBasicInitialWitness() throws {
        let swoir = Swoir()
        let circuitKey = "basic"
        try swoir.addCircuit(key: circuitKey, manifest: "basic.json", bundle: Bundle.module)
        let witnessInputs: [String: Any] = [
            "x": Int(1),
            "y": Int(5),
        ]
        let initialWitness = try swoir.generateInitialWitness(key: circuitKey, inputs: witnessInputs)
        let expected: [String] = [
            "0x0000000000000000000000000000000000000000000000000000000000000001",
            "0x0000000000000000000000000000000000000000000000000000000000000005"
        ]
        XCTAssertEqual(initialWitness, expected)
    }
}
