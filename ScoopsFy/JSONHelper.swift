//
//  JSONHelper.swift
//  ScoopFy
//
//  Created by Pedro Martin Gomez on 6/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import Foundation

//MARK: - KEYS

enum JSONKeys: String {
    case id = "id"
    case newsItemDate = "newsitemdate"
    case author = "author"
    case title = "title"
    case text = "text"
    case photo = "photo"
    case longitude = "longitude"
    case latitude = "latitude"
    case containerName = "containername"
    case published = "published"
    case visible = "visible"
    case votes = "votes"
}

//MARK: - ALIASES

typealias JSONObject        = AnyObject
typealias JSONDictionary    = [String:JSONObject]
typealias JSONArray         = [JSONDictionary]

//MARK: - ERRORS

enum JSONError : ErrorType {
    case WrongURLFormatForJSONResource
    case ResourcePointedByURLNotReachable
    case JSONParsingError
    case WrongJSONFormat
}

//MARK: - STRUCTS

struct StrictNewsItem {
    
    let id           : String?
    let newsItemDate : NSDate
    let author       : String?
    let title        : String?
    let text         : String?
    let urlPhoto     : NSURL
    let latitude     : Double?
    let longitude    : Double?
    var votes        : Int
    var published    : Bool?
    var visible      : Bool?
}

//MARK - DECODING

func decode(newsItem json:JSONDictionary) throws -> StrictNewsItem {
    
    guard let urlImageString = json[JSONKeys.photo.rawValue] as? String, // the image url is present in the JSON document
        urlPhoto = NSURL(string: "\(urlImageString)")
        else {
            throw JSONError.WrongURLFormatForJSONResource
    }
    
    let id = json[JSONKeys.id.rawValue] as! String
    let newsItemDate = json[JSONKeys.newsItemDate.rawValue] as! NSDate
    let author = json[JSONKeys.author.rawValue] as! String
    let title = json[JSONKeys.title.rawValue] as! String
    let text = json[JSONKeys.text.rawValue] as! String
    let latitude = Double.init(json[JSONKeys.latitude.rawValue] as! String)
    let longitude = Double.init(json[JSONKeys.longitude.rawValue] as! String)
    let votes = json[JSONKeys.votes.rawValue] as! Int
    let published = json[JSONKeys.published.rawValue] as! Bool
    let visible = json[JSONKeys.visible.rawValue] as! Bool
    
    
    // everything seems to be ok
    return StrictNewsItem(id: id, newsItemDate: newsItemDate, author: author, title: title, text: text, urlPhoto: urlPhoto, latitude: latitude, longitude: longitude, votes: votes
        , published: published, visible: visible)
    
}

func decode(newsItem json: JSONArray) -> [StrictNewsItem] {
    
    var results = [StrictNewsItem]()
    
    do {
        for dict in json {
            
            //print(dict)
            let item = try decode(newsItem: dict)
            
            results.append(item)
            
        }
        
    } catch {
        fatalError("Error during parsing json array")
    }
    
    return results
    
    
}

//MARK: - INITIALIZATION

extension NewsItem {
    
    // an init that accepts packed parameters in an StrinctAGTBook
    convenience init(strinctNewsItem obj: StrictNewsItem) {
        
        self.init(id: obj.id, newsItemDate: obj.newsItemDate, author: obj.author, title: obj.title, text: obj.text, urlPhoto: obj.urlPhoto, latitude: obj.latitude, longitude: obj.longitude, votes: obj.votes, published: obj.published, visible: obj.visible)
        
    }
}

extension NewsLibrary {
    
    convenience init(news ns: [StrictNewsItem]) {
        
        var arrOfNews = [NewsItem]()
        
        for each in ns {
            
            let n = NewsItem(strinctNewsItem: each)
            arrOfNews.append(n)
            
        }
        
        self.init(arrayOfNewsItem: arrOfNews)
        
    }
    
}









