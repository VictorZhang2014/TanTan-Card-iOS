//
//  SPImageCardDataModel.swift
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/5.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

import Foundation

@objc(SPImageCardDataModel)
class SPImageCardDataModel: NSObject {
    
    var id: String?
    var title: String?
    var img: String?
    var thumb: String?
    var link: String?
    
    public func convert(with dataDict: [String:Any]) {
        if let _id = dataDict["id"] as? String {
            self.id = _id
        }
        if let _title = dataDict["title"] as? String {
            self.title = _title
        }
        if let _img = dataDict["img"] as? String {
            self.img = _img
        }
        if let _thumb = dataDict["thumb"] as? String {
            self.thumb = _thumb
        }
        if let _link = dataDict["link"] as? String {
            self.link = _link
        }
    }
    
}
