//
//  NewsLibrary.swift
//  ScoopFy
//
//  Created by Pedro Martin Gomez on 6/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import Foundation

class NewsLibrary {
    
    //MARK: - Private Inteface
    
    private var news: [NewsItem]
    
    //MARK: - Initialization
    init(arrayOfNewsItem: [NewsItem]) {
        
        // create an empty dictionary
        news = arrayOfNewsItem
    }
    
    var News: [NewsItem] {
        get {
            return self.news
        }
    }
    
    // Total number of books
    var newItemCount: Int {
        
        get {
            return self.news.count
        }
    }
    

}