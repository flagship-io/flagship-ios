import Foundation

public struct FSFeatureConfiguration: Codable {
    let version: String
    let lastUpdated: String
    let features: [String: Feature]
    
    struct Feature: Codable {
        let target: Criteria
    }
    
    struct Criteria: Codable {
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
    
    func meetsSystemCriteria(_ featureKey: String, device: String, os: String, appVersion: String, language: String) -> Bool {
        print("\n=== Feature Check: \(featureKey) ===")
        print("📱 Current System:")
        print("- Device: \(device)")
        print("- OS: \(os)")
        print("- Version: \(appVersion)")
        print("- Language: \(language)")
        
        guard let feature = features[featureKey] else {
            print("❌ Feature not found in configuration")
            return false
        }
        
        let criteria = feature.target
        print("\n📋 Required Criteria:")
        print("- Allowed devices: \(criteria.devices)")
        print("- Allowed OS: \(criteria.os)")
        print("- Min version: \(criteria.minAppVersion)")
        print("- Supported languages: \(criteria.languages)")
        
        // Check device compatibility
        guard criteria.devices.contains(device) else {
            print("❌ Device check failed: \(device) not in \(criteria.devices)")
            return false
        }
        print("✅ Device check passed")
        
        // Check OS compatibility
        guard criteria.os.contains(os) else {
            print("❌ OS check failed: \(os) not in \(criteria.os)")
            return false
        }
        print("✅ OS check passed")
        
        // Check minimum app version
        let versionComparison = compareVersions(appVersion, criteria.minAppVersion)
        guard versionComparison >= 0 else {
            print("❌ Version check failed: \(appVersion) < \(criteria.minAppVersion)")
            return false
        }
        print("✅ Version check passed")
        
        // Check language support
        guard criteria.languages.contains(language) else {
            print("❌ Language check failed: \(language) not in \(criteria.languages)")
            return false
        }
        print("✅ Language check passed")
        
        print("✅ All criteria met for \(featureKey)")
        return true
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
}
