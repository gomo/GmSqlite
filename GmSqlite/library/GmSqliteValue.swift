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
    
    public func string() -> String{
        return NSString(data:value, encoding:NSUTF8StringEncoding)
    }
    
    public func int() -> Int{
        let strbuf:String = string()
        let intbuf:Int? = strbuf.toInt()
        if intbuf == nil {
            NSException(name: "GmSqliteException", reason: "'\(strbuf)' can't convert to integer.", userInfo: nil).raise()
        }
        
        return intbuf!
    }
    
    override public var description: String{
        return string();
    }
}