//
//  FSCampaigns.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation



/////////////// Camapigns //////////////////

public class FSCampaigns:Decodable{
    
    public var visitorId:String!
    
    public var campaigns:[FSCampaign] = []
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        //should create by default ... See later
        do{ self.visitorId              = try values.decode(String.self, forKey: .visitorId)} catch{ self.visitorId = "customId"}
        do{ self.campaigns             = try values.decode([FSCampaign].self, forKey: .campaigns)} catch{ self.campaigns = []}
        
    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case visitorId
        case campaigns
    }
    
    
    //// Get relative information tracking for Value
    public func getRelativeInfoTrackForValue(_ keyValue:String)->[String:String]?{
        
        for item:FSCampaign in self.campaigns{
            
            guard let value = item.variation?.modifications?.value else{
                
                print("no modification at all")
                return nil
            }
            if value.keys.contains(keyValue){
                
                return ["vaid": item.variation!.idVariation, "caid":item.variationGroupId ?? ""]
                
            }else{
                return nil
            }
        }
        return ["":""]
    }
    
    
    
}




//////////////// Campaign ////////////////
public class FSCampaign:Decodable{
    
    
    public  var idCampaign:String = ""
    public var variationGroupId:String?
    public var variation:FSVariation?
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        //should create by default ... See later
        do{ self.idCampaign              = try values.decode(String.self, forKey: .idCampaign)} catch{ self.idCampaign = ""}
        do{ self.variationGroupId              = try values.decode(String.self, forKey: .variationGroupId)} catch{ self.variationGroupId = ""}
        do{ self.variation        = try values.decode(FSVariation.self, forKey: .variation)} catch{ self.variation = nil}
        
    }
    
    
    
    
    
    private enum CodingKeys: String, CodingKey {
        
        case idCampaign = "id"
        case variationGroupId
        case variation
    }
    
    
    // Get The the Infos tracking for key
    
}



////////////////// Variation /////////////
public class FSVariation:Decodable{
    
    public var idVariation:String = ""
    public var modifications:FSModifications?
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        //should create by default ... See later
        do{ self.idVariation              = try values.decode(String.self, forKey: .idVariation)} catch{ self.idVariation = ""}
        do{ self.modifications        = try values.decode(FSModifications.self, forKey: .modifications)} catch{ self.modifications = nil}
        
    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case idVariation = "id"
        case modifications
    }
    
}


////////////// Modification ///////////////

public class FSModifications:Decodable{
    
    public var type:String?
    
    public var value:[String:Any]?
    
    
    required public  init(from decoder: Decoder) throws{
        
        
        if let values =  try? decoder.container(keyedBy: CodingKeys.self){
            
            
            type = try values.decode(String.self, forKey: .type)

            value = try values.decode([String:Any].self, forKey: .value)
            
        }else
        {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case type
        case value
    }
    
}



struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
                        if let boolValue = try? decode(Bool.self, forKey: key) {
                            dictionary[key.stringValue] = boolValue
                        } else if let stringValue = try? decode(String.self, forKey: key) {
                            dictionary[key.stringValue] = stringValue
                        } else if let intValue = try? decode(Int.self, forKey: key) {
                            dictionary[key.stringValue] = intValue
                        } else if let doubleValue = try? decode(Double.self, forKey: key) {
                            dictionary[key.stringValue] = doubleValue
                        } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                            dictionary[key.stringValue] = nestedDictionary
                        } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                            dictionary[key.stringValue] = nestedArray
                        }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }

}



