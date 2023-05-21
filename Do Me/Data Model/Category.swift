//
//  Category.swift
//  Do Me
//
//  Created by Balaji Srinivas on 14/04/23.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color = ""
    //Forward Relationship
    let items = List<Item>()
}
