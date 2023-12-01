//
//  FSModifications.swift
//  Flagship
//
//  Created by Adel on 07/09/2021.
//

class FSModifications: Codable {
    public var type: String?

    public var value: [String: Any]?

    public required init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            self.type = try values.decode(String.self, forKey: .type)

            self.value = try values.decode([String: Any].self, forKey: .value)

        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.value, forKey: .value)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}
