//
//  RealmManager.swift
//  myMessenger
//
//  Created by alex on 14.04.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() { }
    
    func saveToRealm<T: Object>(_ object: T) {
        
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            print("Error saving realm Object ", error.localizedDescription)
        }
    }
    
}
