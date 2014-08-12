//
//  GmSqliteTests.swift
//  GmSqliteTests
//
//  Created by Masamoto Miyata on 2014/08/13.
//  Copyright (c) 2014年 Masamoto Miyata. All rights reserved.
//

import UIKit
import XCTest

class GmSqliteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        GmSqlite.addDatabase(
            "main",
            path: NSBundle.mainBundle().pathForResource("test", ofType: "sqlite3")
        )
        var db:GmSqlite = GmSqlite.database("main")
        db.query("DELETE FROM shop");
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        var db:GmSqlite = GmSqlite.database("main")
        var id:Int = db.insert("shop", params: ["name":"aaa"])
        
        db.fetchAll("SELECT * FROM shop")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
