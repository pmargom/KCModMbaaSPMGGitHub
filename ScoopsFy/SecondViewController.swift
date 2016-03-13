//
//  SecondViewControllerTableViewController.swift
//  ScoopsFy
//
//  Created by Pedro Martin Gomez on 13/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    
    
    @IBOutlet var newsList: UITableView!
    
    var model: NewsLibrary?
    var azureClient: MSClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadData:")
        self.navigationItem.leftBarButtonItem = refreshButton
        
        azureClient = getClientInstance()
        //logUserInSocialNetwork(self)
        loadNews()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //loadNews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Custom methods
    func loadNews() {
        
        //let usrlogin = loadUserAuthInfo()
        let tableName = client?.tableWithName("noticias")
        
        let query = MSQuery(table: tableName)
        
        query.orderByDescending("newsItemDate")
        query.predicate = NSPredicate(format: "visible == %@", true)
        query.readWithCompletion { (result:MSQueryResult?, error:NSError?) -> Void in
            
            if error == nil {
                guard let data = result?.items else {
                    fatalError("Error - loadNews: bad result")
                }
                
                if data.count == 0 {
                    self.model = nil
                    self.newsList.reloadData()
                }
                else {
                    // try to parse JSON
                    if let news = decodeJSON((data as? JSONArray)!) {
                        self.model = NewsLibrary(news: news)
                        self.newsList.reloadData()
                        
                    }
                    else {
                        fatalError("Error during parsing news info")
                    }
                }
            }
            else {
                fatalError("\(error)")
            }
            
        }
        
    }
    
    func reloadData(sender: AnyObject) {
        
        loadNews()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let identifier = segue.identifier else{
            print("No identifier found.")
            return
        }
        
        switch identifier{
        case "detailNewsItem":
            let indexPath = self.tableView.indexPathForSelectedRow
            let vc = segue.destinationViewController as! DetailsNewsItem
            vc.client = client
            vc.model = model?.News[(indexPath?.row)!]
            break
        default: break
            
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if model != nil {
            rows = (model?.newItemCount)!
        }
        
        return rows
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = "AllNewsItemCellId"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! AllNewsItemCell
        
        let newsItem = model?.News[indexPath.row]
        
        cell.photo?.image = UIImage(named: "Blank52")
        cell.titleLabel?.text = newsItem?.author
        cell.authorLabel?.text = newsItem?.title
        
        //        if newsItem?.votes > 0 {
        //            cell.favButton?.image = UIImage(named: "fav.png")
        //        }else {
        //            cell.favButton?.image = UIImage(named: "noFav.png")
        //        }
        
        if let imageUrl = newsItem?.urlPhoto {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(NSMutableURLRequest(URL: imageUrl)) { data, response, error in
                
                guard data != nil else {
                    return
                }
                
                let image = UIImage(data: data!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    cell.photo?.image = image
                    
                })
                
            }
            
            task.resume()
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellID = "AllNewsItemCellId"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! AllNewsItemCell
        
        return cell.bounds.size.height
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            //            tableView.beginUpdates()
            //
            //            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            //            model!.removeAtIndex(indexPath.row)
            //
            //
            //            tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        // the cell needs to subscribe to the favourite notification
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnNotificationForDetails:", name: cellNotificationKey, object: nil)
        
        // the cell needs sent a notification in order to update the webview
        
        //        let book = model![indexPath.row, inTag: model?.tagList[indexPath.section]]
        //        let data = [indexPath.row: book!]
        //        NSNotificationCenter.defaultCenter().postNotificationName(cellNotificationViewPdfKey, object: self, userInfo: data)
        
    }
    
}
