import Foundation

public struct FSFeatureConfiguration: Codable {
    let version: String
    let lastUpdated: String
    let features: [String: Feature]
    
    struct Feature: Codable {
        let target: Target?
    }
    
    struct Target: Codable {
        let devices: [String]
        let os: [String]
        let minAppVersion: String
        let languages: [String]
        let universal: [String: Any]?
        
        // Custom coding keys for handling Any type
        private enum CodingKeys: String, CodingKey {
            case devices, os, minAppVersion, languages, universal
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            devices = try container.decode([String].self, forKey: .devices)
            os = try container.decode([String].self, forKey: .os)
            minAppVersion = try container.decode(String.self, forKey: .minAppVersion)
            languages = try container.decode([String].self, forKey: .languages)
            
            // Decode universal as [String: Any]
            if container.contains(.universal) {
                let universalContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .universal)
                var universalDict: [String: Any] = [:]
                
                for key in universalContainer.allKeys {
                    if let stringValue = try? universalContainer.decode(String.self, forKey: key) {
                        universalDict[key.stringValue] = stringValue
                    } else if let intValue = try? universalContainer.decode(Int.self, forKey: key) {
                        universalDict[key.stringValue] = intValue
                    } else if let doubleValue = try? universalContainer.decode(Double.self, forKey: key) {
                        universalDict[key.stringValue] = doubleValue
                    } else if let boolValue = try? universalContainer.decode(Bool.self, forKey: key) {
                        universalDict[key.stringValue] = boolValue
                    } else if let arrayValue = try? universalContainer.decode([String].self, forKey: key) {
                        universalDict[key.stringValue] = arrayValue
                    }
                }
                universal = universalDict.isEmpty ? nil : universalDict
            } else {
                universal = nil
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(devices, forKey: .devices)
            try container.encode(os, forKey: .os)
            try container.encode(minAppVersion, forKey: .minAppVersion)
            try container.encode(languages, forKey: .languages)
            
            if let universal = universal {
                var universalContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .universal)
                for (key, value) in universal {
                    let codingKey = AnyCodingKey(stringValue: key)!
                    if let stringValue = value as? String {
                        try universalContainer.encode(stringValue, forKey: codingKey)
                    } else if let intValue = value as? Int {
                        try universalContainer.encode(intValue, forKey: codingKey)
                    } else if let doubleValue = value as? Double {
                        try universalContainer.encode(doubleValue, forKey: codingKey)
                    } else if let boolValue = value as? Bool {
                        try universalContainer.encode(boolValue, forKey: codingKey)
                    } else if let arrayValue = value as? [String] {
                        try universalContainer.encode(arrayValue, forKey: codingKey)
                    }
                }
            }
        }
    }
    
    static func decode(from jsonData: Data) throws -> FSFeatureConfiguration {
        let decoder = JSONDecoder()
        return try decoder.decode(FSFeatureConfiguration.self, from: jsonData)
    }
    
    static func loadFromFile(named filename: String = "features") throws -> FSFeatureConfiguration {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(domain: "FSFeatureConfiguration", code: -1, userInfo: [NSLocalizedDescriptionKey: "Features file not found"])
        }
        
        let jsonData = try Data(contentsOf: url)
        return try decode(from: jsonData)
    }
    
    func isFeatureEnabled(_ featureKey: String, device: String, os: String, appVersion: String, language: String, universalContext: [String: String] = [:]) -> Bool {
        print("\n=== Feature Check: \(featureKey) ===")
        print("📱 Current System:")
        print("- Device: \(device)")
        print("- OS: \(os)")
        print("- Version: \(appVersion)")
        print("- Language: \(language)")
        print("- Universal Context: \(universalContext)")
        
        guard let feature = features[featureKey] else {
            print("❌ Feature '\(featureKey)' not found in configuration")
            return false
        }
        
        // If target is missing, feature is enabled with no restrictions
        guard let target = feature.target else {
            print("✅ Feature '\(featureKey)' enabled (no targeting restrictions)")
            return true
        }
        
        print("\n📋 Target Requirements:")
        print("- Allowed devices: \(target.devices)")
        print("- Allowed OS: \(target.os)")
        print("- Min version: \(target.minAppVersion)")
        print("- Supported languages: \(target.languages)")
        if let universal = target.universal {
            print("- Universal requirements: \(universal)")
        }
        
        // Check device compatibility
        guard target.devices.contains(device) else {
            print("❌ Device check failed: \(device) not in \(target.devices)")
            return false
        }
        print("✅ Device check passed")
        
        // Check OS compatibility
        guard target.os.contains(os) else {
            print("❌ OS check failed: \(os) not in \(target.os)")
            return false
        }
        print("✅ OS check passed")
        
        // Check minimum app version
        let versionComparison = compareVersions(appVersion, target.minAppVersion)
        guard versionComparison >= 0 else {
            print("❌ Version check failed: \(appVersion) < \(target.minAppVersion)")
            return false
        }
        print("✅ Version check passed")
        
        // Check language support
        guard target.languages.contains(language) else {
            print("❌ Language check failed: \(language) not in \(target.languages)")
            return false
        }
        print("✅ Language check passed")
        
        // Check universal field requirements
        if let universalRequirements = target.universal {
            for (key, requiredValue) in universalRequirements {
                guard let contextValue = universalContext[key] else {
                    print("❌ Universal check failed: missing key '\(key)' in context")
                    return false
                }
                guard contextValue == requiredValue else {
                    print("❌ Universal check failed: '\(key)' = '\(contextValue)' but required '\(requiredValue)'")
                    return false
                }
            }
            print("✅ Universal checks passed")
        }
        
        print("✅ All criteria met for \(featureKey)")
        return true
    }
    
    private func compareVersions(_ version1: String, _ version2: String) -> Int {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<min(components1.count, components2.count) {
            if components1[i] != components2[i] {
                return components1[i] < components2[i] ? -1 : 1
            }
        }
        return components1.count == components2.count ? 0 : (components1.count < components2.count ? -1 : 1)
    }
}

// Helper struct for dynamic coding keys
struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
