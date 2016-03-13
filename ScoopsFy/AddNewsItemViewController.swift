//
//  AddNewsItemViewController.swift
//  ScoopFy
//
//  Created by Pedro Martin Gomez on 7/3/16.
//  Copyright © 2016 Pedro Martin Gomez. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddNewsItemViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tituloLabel: UITextField!
    @IBOutlet weak var textLabel: UITextField!
    @IBOutlet weak var imageForNewsItem: UIImageView!

    var client: MSClient?
    var model: NewsItem?
    var updated: Bool = false
    var okButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom methods
    func setupUI() {

        //let okButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "okAction:")
        okButton = UIBarButtonItem(title: "Guardar", style: .Plain, target: self, action: "okAction:")
        okButton!.enabled = false
        self.navigationItem.rightBarButtonItem = okButton
        
        self.tituloLabel?.delegate = self
        self.textLabel?.delegate = self
    }
    
    // MARK: - Textfields
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let titleString = tituloLabel.text! as NSString
        let textString = textLabel.text! as NSString
        
        okButton!.enabled = (titleString.length > 0) && (textString.length > 0)
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let titleString = tituloLabel.text! as NSString
        let textString = textLabel.text! as NSString
        
        okButton!.enabled = (titleString.length > 0) && (textString.length > 0)
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Camera
    
    @IBAction func pickImage(sender: AnyObject) {
        
        setupCameraUI()
    }
    
    func setupCameraUI () {
        
        let imagePC = UIImagePickerController()
        imagePC.delegate = self
        
        if (UIImagePickerController.isSourceTypeAvailable(.Camera) == false) {
            imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        else {
            imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        imagePC.allowsEditing = false
        
        self.presentViewController(imagePC, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.imageForNewsItem.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - Save info
    
    func okAction(sender: AnyObject) {
        
        // try to store the new newsItem in azure
        
        saveNewNewsItem()
        
        // go back to parent viewController
        let parentVC = self.parentViewController as? UINavigationController
        parentVC?.popViewControllerAnimated(true)
        
    }
    
    func saveNewNewsItem() {
        
        // loading the user date already logged in
        if let usrlogin = loadUserAuthInfo() {
            client!.currentUser = MSUser(userId: usrlogin.usr)
            client!.currentUser.mobileServiceAuthenticationToken = usrlogin.tok
            
            let tableName = client?.tableWithName("noticias")
            let blobName = "\(NSUUID().UUIDString).png"
            let blobUrl = "\(kEndpointAzureStorage)/\(kContainerName)/\(blobName)"
            
            // 1: Partimos de la base de tener ya el video y en primer lugar guardamos en base de datos
            
            tableName?.insert(["title" : self.tituloLabel.text!, "text" : self.textLabel.text!,
                "photo": blobUrl,
                "longitude": "-16.251846699999987",
                "latitude": "28.4636296",
                "published": false,
                "visible": false,
                "containername" : kContainerName,
                "votes": 0,
                "newsItemDate": NSDate(),
                "author": usrlogin.usr]
                , completion: { (inserted, error: NSError?) -> Void in
                    
                    if error != nil{
                        print("Error - saveNewNewsItem: \(error)")
                        
                    } else {

                        // 2: Persistir el blob en el Storage
                        //print("Primera parte superada (Ya tenemos el registro en la BBDD, ahora toca blob")
                        
                        self.uploadToStorage(UIImagePNGRepresentation((self.imageForNewsItem?.image)!)!, blobName: blobName)
                        
                    }
            })
            
        }
    }
    
    func uploadToStorage(data : NSData, blobName : String){
        
        // vamos a invoke la api urlsastoblobcontainer para obtener una url para poder subir
        
        //1: Invocar la Api
        
        client?.invokeAPI("urlsascontainer",
            body: nil,
            HTTPMethod: "GET",
            parameters: ["blobName": blobName, "containerName" : kContainerName],
            headers: nil,
            completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error: NSError?) -> Void in
                
                if error == nil{
                    
                    // 2: Tenemos solo la ruta del container/blob + la SASURL
                    //let sasURL = result!["sasUrl"] as? String
                    let sasQueryString = result!["sasQueryString"] as? String
                    let hostWithContainerName = result!["hostWithContainerName"] as? String
                    
                    // 3: url del endpoint de Storage
                    //var endPoint = "https://videoblogapppmg.blob.core.windows.net"
                    
                    //endPoint += sasURL!
                    
                    let credentials = AZSStorageCredentials(SASToken: sasQueryString!)
                    
                    // 4: Hemos apuntado al container de AZure Storage
                    let container = AZSCloudBlobContainer(url: NSURL(string: hostWithContainerName!)!, credentials: credentials)
                    //let container = AZSCloudBlobContainer(url: NSURL(string: endPoint)!)
                    
                    // 5: Creamo nuestro blob local
                    
                    let blobLocal = container.blockBlobReferenceFromName(blobName)
                    
                    // 6: Vamos a hacer el upload de nuestro blob local + NSData
                    
                    blobLocal.uploadFromData(data,
                        completionHandler: { (error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    self.okButton!.enabled = false
                                    
                                })
                            } else {
                                print("Tenemos un error -> \(error)")
                            }
                            
                    })
                    
                }
                
        })
        
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














