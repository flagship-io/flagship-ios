import Foundation

public struct FSFeatureConfiguration: Codable {
    let version: String
    let lastUpdated: String
    let features: [String: Feature]
    
    struct Feature: Codable {
        let criteria: Criteria
    }
    
    struct Criteria: Codable {
        let activation: Activation
        let devices: [String]
        let os: [String]
        let minAppVersion: String
        let languages: [String]
    }
    
    struct Activation: Codable {
        let status: Bool
        let startDate: String
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
    
    func isFeatureEnabled(_ featureKey: String) -> Bool {
        guard let feature = features[featureKey] else { return false }
        return feature.criteria.activation.status
    }
    
    func meetsSystemCriteria(_ featureKey: String, device: String, os: String, appVersion: String, language: String) -> Bool {
        guard let feature = features[featureKey] else { return false }
        
        let criteria = feature.criteria
        
        // First check activation status and date
        guard criteria.activation.status else { return false }
        guard isDateValid(criteria.activation.startDate) else { return false }
        
        // Check device compatibility
        guard criteria.devices.contains(device) else { return false }
        
        // Check OS compatibility
        guard criteria.os.contains(os) else { return false }
        
        // Check minimum app version
        guard compareVersions(appVersion, criteria.minAppVersion) >= 0 else { return false }
        
        // Check language support
        guard criteria.languages.contains(language) else { return false }
        
        return true
    }
    
    private func isDateValid(_ startDate: String) -> Bool {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: startDate) else { return false }
        return Date() >= date
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