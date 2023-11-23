//
//  FSTroubleshooting.swift
//  Flagship
//
//  Created by Adel Ferguen on 13/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import UIKit

class FSTroubleshooting: Decodable {
    var startDateString: String
    var endDateString: String
    var timezone: String
    var traffic: Int = 0
    
    var startDate: Date?
    var endDate: Date?
    
    enum CodingKeys: CodingKey {
        case startDate
        case endDate
        case timezone
        case traffic
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.startDateString = try container.decode(String.self, forKey: .startDate)
        self.endDateString = try container.decode(String.self, forKey: .endDate)
        self.timezone = try container.decode(String.self, forKey: .timezone)
        self.traffic = try container.decode(Int.self, forKey: .traffic)
        
        // Convert to date object
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.startDate = formatDate.date(from: startDateString)
        self.endDate = formatDate.date(from: endDateString)
    }
}
