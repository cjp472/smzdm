//
//  ZZGoodArticleModel.swift
//  什么值得买
//
//  Created by Wang_ruzhou on 2017/9/4.
//  Copyright © 2017年 Wang_ruzhou. All rights reserved.
//

import UIKit
import YYKit

class ZZGoodArticleListRequest: ZZBaseRequest {
    var refresh_time: Int
    var size: Int
    
    override init () {
        refresh_time = 1
        size = 5
        super.init()
        urlStr = kZDM_HaoWen
    }
}

class ZZGoodArticleBannerRequest: ZZHomeBannerRequest {
    override init() {
        super.init()
        type = "shequ"
    }
}

class ZZHaoWenTopicListModel: ZZListModel, YYModel {
    
    var id: String?

    var url: String?

    var title_color: String?

    var cell_type: String?

    var img_url: String?

    var title: String?

    var order: String?

    var channel_id: String?

    var filter: String?

    var tab: String?

    var title_bg: String?

    var shaixuan: String?

    var shaixuan_name: String?
    
    var redirect_data: ZZRedirectData?
    
    var rows: [ZZWorthyArticle]?
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["rows" : ZZWorthyArticle.self]
    }
}

class ZZChoicenessListModel: ZZListModel, YYModel {

    var id: String?

    var intro: String?

    var relation_type: String?

    var collection_order: String?

    var position: String?

    var relation_id: String?

    var screening_id: String?

    var collection_type: String?

    var promotion_name: String?

    var link: String?

    var channel: String?

    var title: String?

    var collection_channel: String?

    var promotion_type: String?

    var relation_name: String?

    var yc_rows: [ZZWorthyArticle]?

    var page: String?

    var screening_name: String?

    var vice_title: String?

    var img: String?

    var tag: String?

    var is_show_tag: String?

    var left_tag: String?

    var redirect_data: ZZRedirectData?

    var cell_type: String?
    
    var ga_category: String?

    var article: [ZZWorthyArticle]?

    var ga_brand: String?

    var article_id: String?

    var time_sort: String?
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["article" : ZZWorthyArticle.self,
                "yc_rows" : ZZWorthyArticle.self,]
    }
    
}
