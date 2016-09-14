//
//  MonitorUtil.swift
//  Monitor
//
//  Created by suihong on 16/8/15.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation


class MonitorUtil {
    
    static func UiContentDictionary() -> Dictionary<String, AnyObject>? {
        let uiContentPath:String! = Bundle.main.path(forResource: "UIContent", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: uiContentPath)
        return (dictionary as? Dictionary<String, AnyObject>)
    }
    
    static func GetResourceBundlePath() -> String? {
        return Bundle.main.path(forResource: "resource", ofType: "bundle")
    }
}
