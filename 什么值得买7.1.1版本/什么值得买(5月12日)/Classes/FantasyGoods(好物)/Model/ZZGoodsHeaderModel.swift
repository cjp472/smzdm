//
//  ZZGoodsHeaderModel.swift
//  什么值得买
//
//  Created by Wang_ruzhou on 16/10/9.
//  Copyright © 2016年 Wang_ruzhou. All rights reserved.
//

import UIKit

class ZZGoodsHeaderRequest: ZZBaseRequest {
    
    override init() {
        super.init()
        urlStr = kZDM_HaoWu_Category
    }
}

class ZZGoodsHeaderModel: NSObject {

    var id: String?
    var name: String?
    var picture: String?
    var parent_id: String?
    var level: String?
    var is_leaf: String?
    var wiki_category: String?
    var sort: String?
    var url: String?
    
}
