//
//  Task.swift
//  taskapp
//
//  Created by Yousuke Hasegawa on 2021/08/04.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    
    @objc dynamic var category = ""
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
    
    override static func primaryKey()  -> String? {
        return "id"
    }
    
}
