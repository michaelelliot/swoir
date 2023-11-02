import Foundation

public typealias HexString = String
public typealias Base64String = String

public struct Circuit: Codable {
    let backend: Base64String
    let bytecode: ACIR
    let abi: ABI

    enum CodingKeys: String, CodingKey {
        case backend = "backend"
        case bytecode = "bytecode"
        case abi = "abi"
    }
}

public typealias ACIR = String

public struct ABI: Codable {
    let parameters: [ABI_Parameter]
    let paramWitnesses: [String: [Int]]

    enum CodingKeys: String, CodingKey {
        case parameters = "parameters"
        case paramWitnesses = "param_witnesses"
    }
}

public struct ABI_Parameter: Codable {
    let name: String
    let type: ABI_ParameterType
    let visibility: String

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
        case visibility = "visibility"
    }
}

public indirect enum ABI_ParameterType: Codable {
    case kindInteger(kind: String, sign: String, width: Int)
    case kindArray(kind: String, length: Int, type: ABI_ParameterType)
    case kindField(kind: String)

    enum CodingKeys: CodingKey {
        case kind, sign, width, length, type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "integer":
            let sign = try container.decode(String.self, forKey: .sign)
            let width = try container.decode(Int.self, forKey: .width)
            self = .kindInteger(kind: kind, sign: sign, width: width)
        case "array":
            let length = try container.decode(Int.self, forKey: .length)
            let type = try container.decode(ABI_ParameterType.self, forKey: .type)
            self = .kindArray(kind: kind, length: length, type: type)
        case "field":
            self = .kindField(kind: kind)
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "Unknown kind")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .kindInteger(let kind, let sign, let width):
            try container.encode(kind, forKey: .kind)
            try container.encode(sign, forKey: .sign)
            try container.encode(width, forKey: .width)
        case .kindArray(let kind, let length, let type):
            try container.encode(kind, forKey: .kind)
            try container.encode(length, forKey: .length)
            try container.encode(type, forKey: .type)
        case .kindField(let kind):
            try container.encode(kind, forKey: .kind)
        }
    }
}

public indirect enum Kind {
    case integer(sign: String, width: Int)
    case field
    case array(length: Int, type: ABI_ParameterType)
}

public typealias CircuitName = String
public typealias Circuits = [String: Circuit]
public typealias CircuitAbiParameters = [ABI_Parameter]

public enum SwoirError: Error {
    case errorLoadingManifest(String)
    case errorParsingManifest(String)
    case circuitNotFound(String)
    case missingInput(String)
}

public class Swoir {
    static let shared = Swoir()
    public var circuits: [String: Circuit] = [:]
    public var acir: [UInt8] = []
    public private(set) var allowMissingInputs: Bool

    public init(allowMissingInputs: Bool = false) {
        self.allowMissingInputs = allowMissingInputs
    }

    public func addCircuit(key: String, manifest fileName: String, bundle: Bundle) throws {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw SwoirError.errorLoadingManifest("Couldn't find manifest file in bundle: \(fileName)")
        }
        try addCircuit(key: key, manifest: url)
    }

    public func addCircuit(key: String, manifest url: URL) throws {
        do {
            let data = try Data(contentsOf: url)
            try addCircuit(key: key, manifest: data)
        } catch {
            throw SwoirError.errorLoadingManifest(error.localizedDescription)
        }
    }

    public func addCircuit(key: String, manifest data: Data) throws {
        do {
            let circuit = try parseCircuit(data: data)
            circuits[key] = circuit
        } catch {
            throw SwoirError.errorLoadingManifest(error.localizedDescription)
        }
    }

    public func parseCircuit(data: Data) throws -> Circuit? {
        do {
            let decoder = JSONDecoder()
            let circuit = try decoder.decode(Circuit.self, from: data)

            if let data = Data(base64Encoded: circuit.bytecode) {
                acir = [UInt8](data)
            } else {
                throw SwoirError.errorLoadingManifest("Invalid base64 ACIR bytecode in manifest")
            }

            return circuit
        } catch {
            throw SwoirError.errorParsingManifest(error.localizedDescription)
        }
    }

    public func getCircuit(key: String) throws -> Circuit {
        if !circuits.keys.contains(key) {
            throw SwoirError.circuitNotFound("No circuit with key \(key) found")
        }
        return circuits[key]!
    }

    public func generateInitialWitness(key: String, inputs: [String: Any]) throws -> [HexString] {
        return try generateInitialWitness(circuit: try getCircuit(key: key), inputs: inputs)
    }

    public func generateInitialWitness(circuit: Circuit, inputs: [String: Any]) throws -> [HexString] {
        var initialWitness: [HexString] = []
        for param in circuit.abi.parameters {
            switch param.type {
            case .kindArray(_, let length, let type):
                var arrayTypeWidth = 256 // default to Field width of 256
                if case .kindInteger(_, _, let width) = type { arrayTypeWidth = width }

                let hexWidth = (arrayTypeWidth / 8) * 2
                guard let buffer = inputs[param.name] as? Data else {
                    if (!self.allowMissingInputs) {
                        throw SwoirError.missingInput("Missing witness input: \(param.name)")
                    }
                    continue
                }
                if (buffer.count != length) {
                    throw SwoirError.errorParsingManifest("Length mismatch for \(param.name). Input length is \(buffer.count) but circuit expects \(length)")
                }

                let hexArray = buffer.map { byte -> String in
                    let hexString = String(format: "%02x", byte)
                    let paddedHexString = "0x" + String(repeating: "0", count: hexWidth - hexString.count) + hexString
                    return paddedHexString
                }
                initialWitness.append(contentsOf: hexArray)
            case .kindField:
                let hexWidth = (256 / 8) * 2
                if let integer = inputs[param.name] as? Int {
                    let hexString = String(format: "%02x", integer)
                    let paddedHexString = "0x" + String(repeating: "0", count: hexWidth - hexString.count) + hexString
                    initialWitness.append(paddedHexString)
                }
            case .kindInteger(_, _, let width):
                let hexWidth = (width / 8) * 2
                if let integer = inputs[param.name] as? Int {
                    let hexString = String(format: "%02x", integer)
                    let paddedHexString = "0x" + String(repeating: "0", count: hexWidth - hexString.count) + hexString
                    initialWitness.append(paddedHexString)
                }
            }
        }
        return initialWitness
    }
}
