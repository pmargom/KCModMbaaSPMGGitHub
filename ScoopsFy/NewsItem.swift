//
//  NewsItem.swift
//  ScoopFy
//
//  Created by Pedro Martin Gomez on 6/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import Foundation

class NewsItem {
    
    //MARK: - PROPERTIES
    
    var id           : String?
    var newsItemDate : NSDate?
    var author       : String?
    var title        : String?
    var text         : String?
    var urlPhoto     : NSURL?
    var latitude     : Double?
    var longitude    : Double?
    var votes        : Int     = 0
    var published    : Bool?   = false
    // this value need to change after the NewsItem will be published
    // and the scheduled task in azure has been executed
    var visible      : Bool?   = false
    
    //MARK: - INIT
    
    init(id: String?, newsItemDate: NSDate?, author: String?, title: String?, text: String?, urlPhoto: NSURL?, latitude: Double?, longitude: Double?, votes: Int, published: Bool?, visible: Bool?) {
        
        self.id = id
        self.newsItemDate = newsItemDate
        self.author = author
        self.title = title
        self.text = text
        self.urlPhoto = urlPhoto
        self.latitude = latitude
        self.longitude = longitude
        self.votes = votes
        self.published = published
        self.visible = visible
        
    }
    
    convenience init(votes: Int, published: Bool?, visible: Bool?) {
        
        self.init(id: nil, newsItemDate: nil, author: nil, title: nil, text: nil, urlPhoto: nil, latitude: nil, longitude: nil, votes: votes, published: published, visible: visible)
        
    }
    
}
