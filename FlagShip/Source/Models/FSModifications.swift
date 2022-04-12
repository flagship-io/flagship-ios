//
//  FSModifications.swift
//  Flagship
//
//  Created by Adel on 07/09/2021.
//

internal class FSModifications: Codable {

    public var type: String?

    public var value: [String: Any]?

    required public  init(from decoder: Decoder) throws {

        if let values =  try? decoder.container(keyedBy: CodingKeys.self) {

            type = try values.decode(String.self, forKey: .type)

            value = try values.decode([String: Any].self, forKey: .value)

        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
    }
    
    public func encode(to encoder: Encoder) throws {

    }
    
    private enum CodingKeys: String, CodingKey {

        case type
        case value
    }

}



