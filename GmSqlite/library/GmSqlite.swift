//
//  GmSqlite.swift
//  GmSqlite
//
//  Created by Masamoto Miyata on 2014/08/07.
//  Copyright (c) 2014年 Masamoto Miyata. All rights reserved.
//

import Foundation
var databases:[String: GmSqlite] = [:];
public class GmSqlite:NSObject{
    var db: COpaquePointer = nil
    var dispatch_queue: dispatch_queue_t
    let DISPATCH_QUEUE_LABLE = "GmSqliteQueue"
    
    class func addDatabase(name:String, path:String){
        databases[name] = GmSqlite(dbpath:path)
    }
    
    class func database(name:String) -> GmSqlite{
        var sqlite:GmSqlite? = databases[name]
        
        if !sqlite{
            NSException(name: "GmSQLiteException", reason: "Missing database for name " + name, userInfo: nil).raise()
        }
        
        return sqlite!;
    }
    
    private init(dbpath: String){
        NSLog(dbpath)
        if sqlite3_open(dbpath, &db) != SQLITE_OK {
            sqlite3_close(db)
            NSException(name: "GmSQLiteException", reason: "Missing database file " + dbpath, userInfo: nil).raise()
        }
        
        dispatch_queue = dispatch_queue_create(DISPATCH_QUEUE_LABLE, nil)
    }
    
    public func insert(table:String, params:[String:String]) -> Int{
        var sql:String = "INSERT INTO " + table
        var columns:String = " ("
        var values:String = " VALUES("
        for (key:String, value:String) in params{
            values += "'" + value + "',"
            columns += key + ","
        }
        columns = columns.substringToIndex(advance(columns.endIndex, -1)) + ")"
        values = values.substringToIndex(advance(values.endIndex, -1)) + ")"
        
        sql += columns + values
        
        var id:sqlite3_int64 = 0
        dispatch_sync(dispatch_queue) {
            self.query(sql)
            id = sqlite3_last_insert_rowid(self.db)
        }
        
        return Int(id)
    }
    
    public func fetchAll(sql: String) ->  [[String:GmSqliteValue]]{
        var result:CInt = 0
        var cSql = sql.cStringUsingEncoding(NSUTF8StringEncoding)
        var stmt:COpaquePointer = nil
        var rows = [[String:GmSqliteValue]]()
        
        result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(stmt)
            raiseLastException()
        }
        
        result = sqlite3_step(stmt)
        var colums = [String]();
        while result == SQLITE_ROW {
            let columnCount:CInt = sqlite3_column_count(stmt)
            if colums.count == 0 {
                for index in 0..<columnCount {
                    colums.append(String.fromCString(sqlite3_column_name(stmt, index))!)
                }
            }
            
            var row = [String:GmSqliteValue]()
            for index in 0..<columnCount {
                let columnName = colums[Int(index)];
                let data = sqlite3_column_blob(stmt, index)
                let size = sqlite3_column_bytes(stmt, index)
                let value:GmSqliteValue = GmSqliteValue(value:NSData(bytes:data, length: Int(size)))
                row[columnName] = value;
            }
            
            rows.append(row)
            
            result = sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        
        return rows;
    }
    
    public func query(sql: String) -> Int{
        var result:CInt = 0
        var cSql = sql.cStringUsingEncoding(NSUTF8StringEncoding)
        var stmt:COpaquePointer = nil
        
        //Prepare
        result = sqlite3_prepare_v2(db, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(stmt)
            raiseLastException()
        }
        
        //Step
        result = sqlite3_step(stmt)
        if result != SQLITE_OK && result != SQLITE_DONE {
            sqlite3_finalize(stmt)
            raiseLastException()
        }
        
        // Finalize
        sqlite3_finalize(stmt)
        
        
        return Int(result);
    }
    
    private func raiseLastException(){
        let buf = sqlite3_errmsg(db)
        NSException(name: "GmSQLiteException", reason: NSString(CString:buf, encoding:NSUTF8StringEncoding), userInfo: nil).raise()
    }
}
