//
//  LQSqlite.swift
//  FMDB-Swift
//
//  Created by LiuQiqiang on 2018/4/9.
//  Copyright © 2018年 Artup. All rights reserved.
//

import UIKit

private let defaultDBName: String = "defaultSql.db"
private let lq_allUserTable = "allUserKeys"
class LQSqlite {
    
    private static var dbPath: String?
    private static var dbQueue: FMDatabaseQueue? = {
        
        var path: String = ""
        if let ph = LQSqlite.dbPath {
            path = ph
        }
        
        if path.count == 0 {
            path = LQSqlite.createSqlite()
        }
        
        let dbQ = FMDatabaseQueue.init(path: path)
        return dbQ
    }()
    
    /// 创建SQLite文件
    ///
    /// - Parameter name: SQLite文件名称
    /// - Returns: SQLite文件路径
    @discardableResult
    class func createSqlite(_ name: String = defaultDBName) -> String {
        
        var fileName = ""
        let strArr = name.components(separatedBy: ".")
        if strArr.last == "sqlite" || strArr.last == "db" {
            
            fileName = name
        } else {
            
            fileName = name + ".db"
        }
        
        let path = NSHomeDirectory() + "/Documents/" + fileName
        self.dbPath = path
        return path
    }
    
    /// 删除本地SQLite文件
    ///
    /// - Parameter name: 待删除的SQLite文件名称
    class func deleteSqlite(_ name: String = defaultDBName) {
        
        let path = self.createSqlite(name)
        
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            
            do {
                try fm.removeItem(atPath: path)
            } catch let error {
                print("Error: delete table \(name), \(error.localizedDescription)")
            }
        }
    }
    
    /// 在本地SQLite文件中创建表格
    ///
    /// - Parameters:
    ///   - name: 表格名称
    ///   - keys: 表中的关键字
    class func createTable(_ name: String, withKeys keys: [String]) {
        
        var key = ""
        for ky in keys {
            
            key += ", \(ky) TEXT"
        }
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer { db.close() }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(lq_allUserTable) == false {
                        // 创建一个表来保存用户创建的表中所有的元素
                        let sql = "CREATE TABLE IF NOT EXISTS '\(lq_allUserTable)' (id TEXT NOT NULL, key TEXT NOT NULL)"
                        
                        do {
                            try db.executeUpdate(sql: sql)
                        } catch {}
                    } else {
                        // 如果之前保存过, 为避免重复保存, 先将该表名对应的属性删除
                        if db.tableExists(lq_allUserTable) {
                            
                            do {
                                try db.executeUpdate(sql: "DELETE FROM '\(lq_allUserTable)' WHERE id = '\(name)'")
                            } catch let error {
                                
                                print("Error: delete model from table failed, info: \(error.localizedDescription)")
                            }
                        }
                    }
                    // 保存表中的属性
                    if db.tableExists(lq_allUserTable) {
                        
                        for key in keys {
                            
                            let insert = "INSERT INTO '\(lq_allUserTable)' (id, key) VALUES ('\(name)', '\(key)')"
                            
                            do {
                                try db.executeUpdate(sql: insert)
                            } catch let error {
                                print("Error: insert new obj into table:\(name) failed, info: \(error.localizedDescription)")
                            }
                        }
                    }
                    // 保存内容
                    if db.tableExists(name) == false {
                        
                        let sql = "CREATE TABLE IF NOT EXISTS '\(name)' (id TEXT UNIQUE NOT NULL\(key), date TEXT NOT NULL, PRIMARY KEY(id))"
                        
                        do {
                            try db.executeUpdate(sql: sql)
                        } catch {
                            
                            print("Error: table \(name) create fail")
                        }
                    }
                }
            }
        }
    }
    
    /// 删除数据库SQLite中某个表
    ///
    /// - Parameter name: 待删除的表名
    class func deleteTable(_ name: String) {
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    
                    if db.tableExists(lq_allUserTable) {
                        
                        do {
                            try db.executeUpdate(sql: "DELETE FROM '\(lq_allUserTable)' WHERE id = '\(name)'")
                        } catch let error {
                            
                            print("Error: delete model from table failed, info: \(error.localizedDescription)")
                        }
                    }
                    
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
        }
    }
    
    /// 清空某张表的内容
    ///
    /// - Parameter name: 待清空的表名
    class func clearTable(_ name: String) {
        
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer { db.close() }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(name) {
                        
                        let drop = "DELETE FROM '\(name)'"
                        do {
                            try db.executeUpdate(sql: drop)
                        } catch  {
                            
                            print("Error: table \(name) drop failed")
                        }
                    }
                }
            }
        }
    }
    
    /// 某个表是否存在
    ///
    /// - Parameter name: 表名
    /// - Returns: 是否存在
    class func isTableExists(_ name: String = defaultDBName) -> Bool {
        
        var rs = false
        
        LQSqlite.dbQueue?.inDatabase({ (db) in
            if let db = db {
                
                rs = db.tableExists(name)
            }
        })
        
        return rs
    }
    
    /// 往一个表中新加一个属性
    ///
    /// - Parameters:
    ///   - element: 属性名称
    ///   - table: 添加到的表
    class func alter(_ element: String, toTable table: String) {
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(lq_allUserTable) {
                        
                        let insert = "INSERT INTO '\(lq_allUserTable)' (id, key) VALUES ('\(table)', '\(element)')"
                        
                        do {
                            try db.executeUpdate(sql: insert)
                        } catch let error {
                            print("Error: insert new obj into table:\(lq_allUserTable) failed, info: \(error.localizedDescription)")
                        }
                    }
                    
                    if db.tableExists(table) {
                        
                        do {
                            try db.executeUpdate(sql: "ALTER TABLE '\(table)' ADD '\(element)' TEXT")
                        } catch let error{
                            
                            print("Error:\(error) -- alter new element: \"\(element)\" to table: \"\(table)\" failed")
                        }
                    } else {
                        print("Error:table named \(table) not exists!")
                    }
                }
            }
        }
    }
    
    /// 往某个表中新加元素
    ///
    /// - Parameters:
    ///   - obj: 新加的元素字典
    ///   - id: 元素的唯一标识符
    ///   - name: 表名
    class func insert(_ obj: [String: Any], byID id: String, toTable name: String) {
        
        var allKeys = obj.keys
        
        let date = Date()
        
        var keys: String = ""
        var values: String = ""
        for key in allKeys {
            
            keys += ", \(key)"
            values += ", '\(obj[key] ?? "")'"
        }
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer { db.close() }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(name) {
                        
                        let insert = "INSERT INTO '\(name)' (id \(keys), date) VALUES ('\(id)' \(values), '\(date)')"
                        
                        do {
                            try db.executeUpdate(sql: insert)
                        } catch let error {
                            print("Error: insert new obj into table:\(name) failed, info: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    /// 更新表中某条数据
    ///
    /// - Parameters:
    ///   - obj: 待更新的数据
    ///   - id: 数据的唯一识别符
    ///   - name: 表名
    class func update(_ obj: [String: Any], byID id: String, toTable name: String) {
        
        var keys = obj.keys
        var sqlStr: String = ""
        
        for key in keys {
            sqlStr += "\(key) = '\(obj[key] ?? "")', "
        }
        
        let date = Date()
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(name) {
                        
                        let update = "UPDATE '\(name)' SET \(sqlStr) date = '\(date)' WHERE id = '\(id)'"
                        
                        do {
                            try db.executeUpdate(sql: update)
                        } catch let error  {
                            
                            print("Error: update table: \"\(name)\" failed, info: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    /// 删除某条数据
    ///
    /// - Parameters:
    ///   - id: 数据的唯一识别符
    ///   - table: 表名
    class func delete(byID id: String, fromTable table: String) {
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(table) {
                        
                        do {
                            try db.executeUpdate(sql: "DELETE FROM '\(table)' WHERE id = '\(id)'")
                        } catch let error {
                            
                            print("Error: delete model from table: \"\(table)\" failed, info: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    /// 查找表中所有的元素
    ///
    /// - Parameter table: 表名
    /// - Returns: 所有元素的集合
    class func query(_ table: String) -> [[String: Any]] {
        
        var temps = [[String: Any]]()
        var keys: [String] = []
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    
                    if db.tableExists(lq_allUserTable) {
                        
                        do {
                            let fs = try db.executeQuery(sql: "SELECT * FROM '\(lq_allUserTable)' WHERE id = '\(table)'")
                            while fs.next() {
                                
                                if let rs = fs.string(forColumn: "key") {
                                    keys.append(rs)
                                }
                            }
                            
                            fs.close()
                        } catch  {
                        }
                    }
                    
                    if db.tableExists(table) {
                        
                        let select = "SELECT * FROM '\(table)'"
                        do {
                            let fs = try db.executeQuery(sql: select)
                            
                            while fs.next() {
                                
                                var temp = [String: Any]()
                                if let id = fs.string(forColumn: "id") {
                                    temp["id"] = id
                                }
                                for key in keys {
                                    if let value = fs.object(forColumnName: key) {
                                        temp[key] = value
                                    }
                                }
                                
                                if let date = fs.date(forColumn: "date") {
                                    temp["date"] = date
                                }
                                temps.append(temp)
                            }
                            
                            fs.close()
                        } catch  {
                            
                            print("Error: select models from table: \"\(table)\" failed")
                        }
                    }
                }
            }
        }
        
        return temps
    }
    
    /// 查询某条数据
    ///
    /// - Parameters:
    ///   - id: 数据的唯一识别符
    ///   - table: 表名
    /// - Returns: 数据内容
    class func query(byID id: String, fromTable table: String) -> [String: Any] {
        
        var keys: [String] = []
        var temps: [String: Any] = [:]
        
        LQSqlite.dbQueue?.inDatabase { (db) in
            
            if let db = db {
                
                defer {
                    
                    db.close()
                }
                
                if db.open() {
                    
                    db.setShouldCacheStatements(true)
                    if db.tableExists(lq_allUserTable) {
                        
                        do {
                            let fs = try db.executeQuery(sql: "SELECT * FROM '\(lq_allUserTable)' WHERE id = '\(table)'")
                            while fs.next() {
                                
                                if let rs = fs.string(forColumn: "key") {
                                    keys.append(rs)
                                }
                            }
                            
                            fs.close()
                        } catch  {
                        }
                    }
                    
                    if db.tableExists(table) {
                        
                        do {
                            let fs = try db.executeQuery(sql: "SELECT * FROM '\(table)' WHERE id = '\(id)'")
                            if fs.next() {
                                
                                if let id = fs.string(forColumn: "id") {
                                    temps["id"] = id
                                }
                                
                                for key in keys {
                                    
                                    if let value = fs.object(forColumnName: key) {
                                        temps[key] = value
                                    }
                                }
                                
                                if let date = fs.date(forColumn: "date") {
                                    temps["date"] = date
                                }
                            }
                            
                            fs.close()
                        } catch  {
                            
                            print("Error: select model from table: \"\(table)\" with id: \"\(id)\" failed")
                        }
                    }
                }
            }
        }
        
        return temps
    }
    
    /// 某个表中所有元素总和
    ///
    /// - Parameter table: 表名
    /// - Returns: 数据条数
    class func count(of table: String) -> Int {
        
        var count = 0
        LQSqlite.dbQueue?.inDatabase { (db) in
            
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
        }
        
        return count
    }
    
//    MARK: - 私有方法
    private func toJSON(_ obj: Any) -> String? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            let str = String.init(data: data, encoding: String.Encoding.utf8)
            
            return str
        } catch let error {
            
            print("Error: obj to json failed, info: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private func toOBJ(_ json: String) -> Any? {
        
        if let dt = json.data(using: String.Encoding.utf8) {
            
            do {
                let obj = try JSONSerialization.jsonObject(with: dt, options: JSONSerialization.ReadingOptions.allowFragments)
                
                return obj
            } catch let error {
                
                print("Error: obj to json failed, info: \(error.localizedDescription)")
            }
        }
        return nil
    }
     
}


