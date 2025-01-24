//
//  FSAccountSettings.swift
//  Flagship
//
//  Created by Adel Ferguen on 13/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class FSExtras: Decodable {
    var accountSettings: FSAccountSettings?
    
    enum CodingKeys: CodingKey {
        case accountSettings
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accountSettings = try container.decode(FSAccountSettings.self, forKey: .accountSettings)
    }
    
    init(_ accountSettings: FSAccountSettings?) {
        self.accountSettings = accountSettings
    }
}

class FSAccountSettings: Decodable {
    var enabledXPC: Bool = false
    var enabled1V1T: Bool = false
    var eaiCollectEnabled: Bool = false
    var eaiActivationEnabled: Bool = false
    
    var troubleshooting: FSTroubleshooting?
    
    enum CodingKeys: CodingKey {
        case enabledXPC
        case enabled1V1T
        case troubleshooting
        case eaiCollectEnabled
        case eaiActivationEnabled
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do { self.enabledXPC = try container.decode(Bool.self, forKey: .enabledXPC) } catch { self.enabledXPC = false }
        do { self.enabled1V1T = try container.decode(Bool.self, forKey: .enabled1V1T) } catch { self.enabled1V1T = false }
        do { self.troubleshooting = try container.decode(FSTroubleshooting.self, forKey: .troubleshooting) } catch {
            self.troubleshooting = nil
        }
         
        do { self.eaiCollectEnabled = try container.decode(Bool.self, forKey: .eaiCollectEnabled) } catch { self.eaiCollectEnabled = false }
        do { self.eaiActivationEnabled = try container.decode(Bool.self, forKey: .eaiActivationEnabled) } catch { self.eaiActivationEnabled = false
        }
    }
    
    public init() {}
}
