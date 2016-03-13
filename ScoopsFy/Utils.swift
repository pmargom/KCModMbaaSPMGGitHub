//
//  Helpers.swift
//  ScoopFy
//
//  Created by Pedro Martin Gomez on 6/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

//import Foundation
import UIKit

// MARK: - Azure endopoints and keys
let kEndpointMobileService = "https://scoopfymobserv.azure-mobile.net/"
let kAppKeyMobileService = "LPXyYsSnJTQdprpbkleiykNKRFbdaT62"
let kEndpointAzureStorage = "https://scoopfystore.blob.core.windows.net"
let kContainerName = "news"

let client = MSClient(
    applicationURLString: kEndpointMobileService,
    applicationKey: kAppKeyMobileService
)

// MARK: - Azure in methods

func getClientInstance() -> MSClient {
    
    return client
    
}

func logUserInSocialNetwork(controller: UIViewController) {

    client.loginWithProvider("facebook", controller: controller, animated: true, completion: { (user: MSUser?, error: NSError?) -> Void in
        
        if (error != nil){
            print("Error - logUserInSocialNetwork: \(error)")
            
        } else{
            
            // Save user credentials in local storage
            saveAuthInfo(user)
            
        }
    })
    
}

func saveAuthInfo (currentUser : MSUser?){
    
    NSUserDefaults.standardUserDefaults().setObject(currentUser?.userId, forKey: "userId")
    NSUserDefaults.standardUserDefaults().setObject(currentUser?.mobileServiceAuthenticationToken, forKey: "tokenId")
    
}

func loadUserAuthInfo() -> (usr : String, tok : String)? {
    
    let user = NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String
    let token = NSUserDefaults.standardUserDefaults().objectForKey("tokenId") as? String
    
    if (user == nil && token == nil) {
        return ("", "")
    }
    return (user!, token!)
}

func isUserloged() -> Bool {
    
    var result = false
    
    let userID = NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String
    
    if let _ = userID {
        result = true
    }
    
    return result
    
}

// MARK: - Local storage folder for blobs
func saveInDocuments(data : NSData) -> NSURL {
    
    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let writePath = documents.stringByAppendingString("/scoopfytemp.mov")
    
    let array = NSArray(contentsOfFile: writePath) as? [String]
    
    if array == nil {
        
        data.writeToFile(writePath, atomically: true)
        
    }
    
    return (NSURL(fileURLWithPath: writePath))
}

// MARK: - Utils methods

func initDateWithString(string: String) -> NSDate {
    
    let dateFormatter = NSDateFormatter()
    /*find out and place date format from http://userguide.icu-project.org/formatparse/datetime*/
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let date = dateFormatter.dateFromString(string)
    return date!
    
}

func initStringFromDate(date: NSDate) -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.stringFromDate(date)
    
}

//MARK: - JSON Decoding

func decodeJSON(newsArray: JSONArray) ->[StrictNewsItem]?{
    
    var result : [StrictNewsItem]? = nil
    
    result = decode(newsItem: newsArray)
    
    return result;
    
}

