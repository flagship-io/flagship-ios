//
//  FSProfile.swift
//  FlagShip
//
//  Created by Adel on 23/10/2019.
//

import  Foundation
// typealias TupleId = (fsUserId:String , visitorId:String?)

  class FSProfile: NSObject {

    var visitorId: String

    init(_ visitorId: String) {

        self.visitorId = visitorId
    }
}
