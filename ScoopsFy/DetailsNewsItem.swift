//
//  DetailsNewsItem.swift
//  ScoopFy
//
//  Created by Pedro Martin Gomez on 7/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import UIKit

class DetailsNewsItem: UITableViewController {

    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var publishedButton: UIButton!
    @IBOutlet weak var votesButton: UIButton!

    var model: NewsItem?
    var client: MSClient?
    var updated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        
        self.navigationItem.title = model?.title
        
        if let imageUrl = model?.urlPhoto {
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(NSMutableURLRequest(URL: imageUrl)) { data, response, error in
                
                guard data != nil else {
                    return
                }
                
                let image = UIImage(data: data!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.topImage?.image = image
                    
                })
                
            }
            
            task.resume()
        }
        dateLabel?.text = initStringFromDate((model?.newsItemDate)!)
        authorLabel?.text = model?.author
        titleLabel?.text = model?.title
        textLabel?.text = model?.text
        
        let usrlogin = loadUserAuthInfo()
        if usrlogin!.usr == model?.author {
            if (model?.published?.boolValue == false) {
                self.publishedButton?.hidden = false
                self.publishedLabel?.hidden = false
                setNewsItemState((model?.published)!)
            }
            else {
                self.publishedButton?.hidden = true
                self.publishedLabel?.hidden = true
            }

            self.votesButton?.enabled = false
            self.votesLabel?.enabled = false
            setNewsItemVotes((model?.votes)!)
        }
        else {
            self.publishedButton?.hidden = true
            self.publishedLabel?.hidden = true
            self.votesButton?.enabled = true
            self.votesLabel?.enabled = true
            setNewsItemVotes((model?.votes)!)
        }
        
    }
    
    func setNewsItemState(state: Bool) {
        
        if (state) {
            self.publishedLabel?.text = "despublicar"
            self.publishedButton?.setImage(UIImage(named: "Like-Filled-50.png"), forState: .Normal)
        }
        else {
            self.publishedLabel?.text = "publicar"
            self.publishedButton?.setImage(UIImage(named: "Like-50.png"), forState: .Normal)
        }
        
    }
    
    func setNewsItemVotes(votes: Int) {
        
        votesLabel?.text = String(votes)
        if (votes > 0) {
            self.votesButton?.setImage(UIImage(named: "Like-Filled-50.png"), forState: .Normal)
        }
        else {
            self.votesButton?.setImage(UIImage(named: "Like-50.png"), forState: .Normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func markUnMarkAsPublished(sender: AnyObject) {
    
        // loading the user date already logged in
        if let usrlogin = loadUserAuthInfo() {
            client!.currentUser = MSUser(userId: usrlogin.usr)
            client!.currentUser.mobileServiceAuthenticationToken = usrlogin.tok
            
            let tableName = client?.tableWithName("noticias")
            let state = !(model?.published)!
            
            tableName?.update(["id" : (model?.id)!, "published": state]
                , completion: { (updated, error: NSError?) -> Void in
                    
                    if error != nil{
                        print("Error - markUnMarkAsPublished: \(error)")
                        
                    }
                    else {
                        self.updated = true
                        self.model?.published = state
                        self.setNewsItemState(state)
                    }
            })
            
        }
        
    }
    
    @IBAction func addVote(sender: AnyObject) {
        
        // loading the user date already logged in
        if let usrlogin = loadUserAuthInfo() {
            client!.currentUser = MSUser(userId: usrlogin.usr)
            client!.currentUser.mobileServiceAuthenticationToken = usrlogin.tok
            
            let tableName = client?.tableWithName("noticias")
            let votes = (model?.votes)! + 1
            
            tableName?.update(["id" : (model?.id)!, "votes": votes]
                , completion: { (updated, error: NSError?) -> Void in
                    
                    if error != nil{
                        print("Error - markUnMarkAsPublished: \(error)")
                        
                    }
                    else {
                        self.updated = true
                        self.model?.votes = (self.model?.votes)! + 1
                        self.setNewsItemVotes(votes)
                        
                    }
            })
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
