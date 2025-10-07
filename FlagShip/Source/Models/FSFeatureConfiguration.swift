import Foundation

public class FSFeatureConfiguration: Decodable {
    let version: String
    let lastUpdated: String
    let accountSettings: AccountSettings?
    let features: [String: Feature]
    
    public class AccountSettings: Decodable {
        let enabledXPC: Bool
        let troubleshooting: FSTroubleshooting?
    }
    
    class Feature: Codable {
        let target: Target?
        let config: [String: Any]?
        
        // Custom coding keys for handling Any type
        private enum CodingKeys: String, CodingKey {
            case target, config
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            target = try container.decodeIfPresent(Target.self, forKey: .target)
            
            // Decode config as [String: Any]
            if container.contains(.config) {
                let configContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .config)
                var configDict: [String: Any] = [:]
                
                for key in configContainer.allKeys {
                    if let stringValue = try? configContainer.decode(String.self, forKey: key) {
                        configDict[key.stringValue] = stringValue
                    } else if let intValue = try? configContainer.decode(Int.self, forKey: key) {
                        configDict[key.stringValue] = intValue
                    } else if let doubleValue = try? configContainer.decode(Double.self, forKey: key) {
                        configDict[key.stringValue] = doubleValue
                    } else if let boolValue = try? configContainer.decode(Bool.self, forKey: key) {
                        configDict[key.stringValue] = boolValue
                    } else if let arrayValue = try? configContainer.decode([String].self, forKey: key) {
                        configDict[key.stringValue] = arrayValue
                    }
                }
                config = configDict.isEmpty ? nil : configDict
            } else {
                config = nil
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(target, forKey: .target)
            
            if let config = config {
                var configContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .config)
                for (key, value) in config {
                    let codingKey = AnyCodingKey(stringValue: key)!
                    if let stringValue = value as? String {
                        try configContainer.encode(stringValue, forKey: codingKey)
                    } else if let intValue = value as? Int {
                        try configContainer.encode(intValue, forKey: codingKey)
                    } else if let doubleValue = value as? Double {
                        try configContainer.encode(doubleValue, forKey: codingKey)
                    } else if let boolValue = value as? Bool {
                        try configContainer.encode(boolValue, forKey: codingKey)
                    } else if let arrayValue = value as? [String] {
                        try configContainer.encode(arrayValue, forKey: codingKey)
                    }
                }
            }
        }
    }
    
    class Target: Codable {
        let devices: [String]
        let os: [String]
        let minAppVersion: String
        let languages: [String]
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
    
    func isFeatureEnabled(_ featureKey: String, device: String, os: String, appVersion: String, language: String) -> Bool {
        print("\n=== Feature Check: \(featureKey) ===")
        print("📱 Current System:")
        print("- Device: \(device)")
        print("- OS: \(os)")
        print("- Version: \(appVersion)")
        print("- Language: \(language)")
        
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
        
        print("✅ All criteria met for \(featureKey)")
        return true
    }
    
    // Method to get feature configuration after feature is enabled
    func getFeatureConfig(_ featureKey: String) -> [String: Any]? {
        guard let feature = features[featureKey] else { return nil }
        return feature.config
    }
    
 
    private func compareVersions(_ version1: String, _ version2: String) -> Int {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }
        
        for i in 0 ..< min(components1.count, components2.count) {
            if components1[i] != components2[i] {
                return components1[i] < components2[i] ? -1 : 1
            }
        }
        return components1.count == components2.count ? 0 : (components1.count < components2.count ? -1 : 1)
    }
    
    private func compareAnyValues(_ value1: Any, _ value2: Any) -> Bool {
        // String comparison
        if let str1 = value1 as? String, let str2 = value2 as? String {
            return str1 == str2
        }
        
        // Int comparison
        if let int1 = value1 as? Int, let int2 = value2 as? Int {
            return int1 == int2
        }
        
        // Double comparison
        if let double1 = value1 as? Double, let double2 = value2 as? Double {
            return double1 == double2
        }
        
        // Bool comparison
        if let bool1 = value1 as? Bool, let bool2 = value2 as? Bool {
            return bool1 == bool2
        }
        
        // Array comparison
        if let array1 = value1 as? [String], let array2 = value2 as? [String] {
            return array1 == array2
        }
        
        // Cross-type numeric comparison (Int vs Double)
        if let int1 = value1 as? Int, let double2 = value2 as? Double {
            return Double(int1) == double2
        }
        if let double1 = value1 as? Double, let int2 = value2 as? Int {
            return double1 == Double(int2)
        }
        
        // String representation fallback
        return "\(value1)" == "\(value2)"
    }
}

// Helper struct for dynamic coding keys
class AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    required init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    required init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
