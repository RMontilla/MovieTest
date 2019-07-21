//
//  MovieObject.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/20/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import RealmSwift

public class MovieObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?

    override public class func primaryKey() -> String? {
        return "id"
    }
}
