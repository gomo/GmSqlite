//
//  GmSqliteValue.swift
//  GmSqlite
//
//  Created by Masamoto Miyata on 2014/08/13.
//  Copyright (c) 2014年 Masamoto Miyata. All rights reserved.
//

import Foundation
public class GmSqliteValue:NSObject {
    private let value:NSData
    init(value:NSData){
        self.value = value
    }
    
    override public var description: String{
        return NSString(data:value, encoding:NSUTF8StringEncoding)
    }
}