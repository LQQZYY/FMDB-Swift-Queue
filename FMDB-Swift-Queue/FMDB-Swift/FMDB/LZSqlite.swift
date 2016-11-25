//
//  LZSqlite.swift
//  FMDB-Swift
//
//  Created by Artron_LQQ on 2016/11/23.
//  Copyright © 2016年 Artup. All rights reserved.
//

import UIKit

class LZSqlite {
    
    private static var path: String!
    private static var queue: FMDatabaseQueue = {
        
        if LZSqlite.path == nil || (LZSqlite.path.characters.count) <= 0 {
            
            LZSqlite.createSqliteFileWithName("myDB.db")
        }
        
        let dbQ = FMDatabaseQueue.init(path: LZSqlite.path)
        
        return dbQ!
    }()
    
    static func createSqliteFileWithName(_ name: String) {
        
        var fileName = ""
        let strArr = name.components(separatedBy: ".")
        
        if strArr.last == "sqlite" || strArr.last == "db" {
            
            fileName = name
        } else {
            
            fileName = name + ".db"
        }
        
        let path = NSHomeDirectory() + "/Documents/" + fileName
        
        LZSqlite.path = path
        
        let fm = FileManager.default
        
        if fm.fileExists(atPath: path) == false {
            
            fm.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        print("dataBase path: \(LZSqlite.path)")
    }
    
    static func clearSqliteFile() {
        
        let fm = FileManager.default
        
        if fm.fileExists(atPath: LZSqlite.path) {
            
            try! fm.removeItem(atPath: LZSqlite.path)
        }
    }
    
    static func createTable(_ name: String) {
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(name) == false {
                        
                        let create = "CREATE TABLE IF NOT EXISTS '\(name)' (ID TEXT UNIQUE NOT NULL, groupName TEXT, groupID TEXT NOT NULL, nickName TEXT, userName TEXT, psw TEXT, urlString TEXT, email TEXT, dsc TEXT)"
                        
                        do {
                            try db.executeUpdate(sql: create)
                        } catch {
                            
                            print("Error: table \(name) create fail")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    
    static func deleteTable(_ name: String) {
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(name) {
                       
                        let drop = "DROP TABLE '\(name)'"
                        
                        do {
                            try db.executeUpdate(sql: drop)
                        } catch  {
                            
                            print("Error: table \(name) drop failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    
    static func alterElement(_ element: String, toTable table: String) {
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        do {
                            try db.executeUpdate(sql: "ALTER TABLE '\(table)' ADD '\(element)' TEXT")
                        } catch let error{
                            
                            print("Error:\(error) -- alter new element: \"\(element)\" to table: \"\(table)\" failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    static func insertOptional(model: LZDataModel, toTable table: String) {
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        var identifier: String = ""
                        var groupName: String = ""
                        var nickName: String = ""
                        var userName: String = ""
                        var password: String = ""
                        var urlString: String = ""
                        var email: String = ""
                        var dsc: String = ""
                        var groupID: String = ""
                        
                        if let tmp = model.identifier {
                            
                            identifier = tmp
                        }
                        
                        if let tmp = model.groupName {
                            groupName = tmp
                        }
                        
                        if let tmp = model.nickName {
                            nickName = tmp
                        }
                        
                        if let tmp = model.userName {
                            userName = tmp
                        }
                        
                        if let tmp = model.password {
                            password = tmp
                        }
                        
                        if let tmp = model.urlString {
                            urlString = tmp
                        }
                        
                        if let tmp = model.email {
                            email = tmp
                        }
                        
                        if let tmp = model.dsc {
                            dsc = tmp
                        }
                        
                        if let tmp = model.groupID {
                            groupID = tmp
                        }
                        
                        let insert = "INSERT INTO '\(table)' (ID, groupName, nickName, userName, psw, urlString, email, dsc, groupID) VALUES ('\(identifier)', '\(groupName)', '\(nickName)', '\(userName)', '\(password)', '\(urlString)', '\(email)', '\(dsc)', '\(groupID)')"
                        
                        do {
                            try db.executeUpdate(sql: insert)
                        } catch {
                            
                            print("Error: insert new model into table:\(table) failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    static func insert(model: LZDataModel, toTable table: String) {
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        let insert = "INSERT INTO '\(table)' (ID, groupName, nickName, userName, psw, urlString, email, dsc, groupID) VALUES ('\(model.identifier)', '\(model.groupName)', '\(model.nickName)', '\(model.userName)', '\(model.password)', '\(model.urlString)', '\(model.email)', '\(model.dsc)', '\(model.groupID)')"
                        
                        do {
                            try db.executeUpdate(sql: insert)
                        } catch {
                            
                            print("Error: insert new model into table:\(table) failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    static func update(model: LZDataModel, inTable table: String) {
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        let update = "UPDATE '\(table)' SET userName = '\(model.userName)', psw = '\(model.password)', nickName = '\(model.userName)', groupName = '\(model.groupName)', dsc = '\(model.dsc)', urlString = '\(model.urlString)', groupID = '\(model.groupID)', email = '\(model.email)' WHERE ID = '\(model.identifier)'"
                        
                        do {
                            try db.executeUpdate(sql: update)
                        } catch  {
                            
                            print("Error: update table: \"\(table)\" failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    static func delete(model: LZDataModel, fromTable table: String) {
        
        
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        do {
                            try db.executeUpdate(sql: "DELETE FROM '\(table)' WHERE ID = '\(model.identifier)'")
                        } catch  {
                            
                            print("Error: delete model from table: \"\(table)\" failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    }
    
    static func selectAllFromTable(_ table: String) -> [LZDataModel]? {
        
        var tempModels = [LZDataModel]()
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        let select = "SELECT * FROM '\(table)'"
                        do {
                            let fs = try db.executeQuery(sql: select)
                            
                            while fs.next() {
                                
                                let model = LZDataModel()
                                model.identifier = fs.string(forColumn: "ID")
                                model.nickName = fs.string(forColumn: "nickName")
                                model.userName = fs.string(forColumn: "userName")
                                model.password = fs.string(forColumn: "psw")
                                model.urlString = fs.string(forColumn: "urlString")
                                model.dsc = fs.string(forColumn: "dsc")
                                model.groupName = fs.string(forColumn: "groupName")
                                model.groupID = fs.string(forColumn: "groupID")
                                model.email = fs.string(forColumn: "email")
                                
                                tempModels.append(model)
                            }
                            
                            fs.close()
                        } catch  {
                            
                            print("Error: select models from table: \"\(table)\" failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
        
        return tempModels
    }
    
    static func selectModelWithID(_ identifier: String, fromTable table: String) -> LZDataModel? {
        
        var model: LZDataModel? = nil
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        do {
                            let fs = try db.executeQuery(sql: "SELECT * FROM '\(table)' WHERE ID = '\(identifier)'")
                            if fs.next() {
                                
                                model = LZDataModel()
                                model?.identifier = fs.string(forColumn: "ID")
                                model?.nickName = fs.string(forColumn: "nickName")
                                model?.userName = fs.string(forColumn: "userName")
                                model?.password = fs.string(forColumn: "psw")
                                model?.urlString = fs.string(forColumn: "urlString")
                                model?.dsc = fs.string(forColumn: "dsc")
                                model?.groupName = fs.string(forColumn: "groupName")
                                model?.groupID = fs.string(forColumn: "groupID")
                                model?.email = fs.string(forColumn: "email")
                                
                                fs.close()
                            }
                        } catch  {
                            
                            print("Error: select model from table: \"\(table)\" with id: \"\(identifier)\" failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
        
        return model
    }
    
    static func selectPart(_ range: CountableClosedRange<Int>, fromTable table: String) -> [LZDataModel]? {
    
        var tempModels = [LZDataModel]()
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        let select = "SELECT * FROM '\(table)' LIMIT \(range.lowerBound), \(range.upperBound - range.lowerBound)"
                        
                        
                        do {
                            let fs = try db.executeQuery(sql: select)
                            
                            while fs.next() {
                                
                                let model = LZDataModel()
                                model.identifier = fs.string(forColumn: "ID")
                                model.nickName = fs.string(forColumn: "nickName")
                                model.userName = fs.string(forColumn: "userName")
                                model.password = fs.string(forColumn: "psw")
                                model.urlString = fs.string(forColumn: "urlString")
                                model.dsc = fs.string(forColumn: "dsc")
                                model.groupName = fs.string(forColumn: "groupName")
                                model.groupID = fs.string(forColumn: "groupID")
                                model.email = fs.string(forColumn: "email")
                                
                                tempModels.append(model)
                            }
                            
                            fs.close()
                            
                        } catch {
                            
                            print("Error: select models from table: \"\(table)\" failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
        
        return tempModels
    }

    static func countOf(table: String) -> Int {
        
        var count = 0
        LZSqlite.queue.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                       
                        do {
                            let fs = try db.executeQuery(sql: "SELECT count(*) FROM '\(table)'")
                            
                            
                            if fs.next() {
                                
                                count = Int(fs.int(forColumn: "count(*)"))
                            }
                            
                            fs.close()
                        } catch  {
                            
                            print("Error: select the element count of \(table) failed")
                        }
                    }
                }
            }
            
//            db?.close()
        }
    
        return count
    }
}
