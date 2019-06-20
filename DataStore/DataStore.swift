//
//  DataStore.swift
//  DataStore
//
//  Created by Markus Faßbender on 20.06.19.
//

import Foundation
import RealmSwift

public struct DataStore {
    public static let shared = DataStore()
    
    let realm: Realm = try! Realm()
}
