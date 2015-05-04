//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    
    @IBAction func stepperChanged(sender: AnyObject) {
        if let o = sharedObject {
            o["myProp"] = stepper.value
            self.refreshLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var sharedObject:PFObject! {
        didSet {
            println("sharedObject: \(sharedObject.objectId)")
            refreshLabel ()
            SVProgressHUD.showSuccessWithStatus("")
        }
    }
    
    func refreshLabel () {
        if let o = sharedObject {
            let v = o["myProp"] as! Double
            stepper.value = v
            label.text = "\(v)"
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.showInfoWithStatus("Setting Up", maskType: .Gradient)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getLocalSharedObject { (obj) -> Void in
            if let o = obj {
                self.sharedObject = o
            }
            else {
                self.getRemoteSharedObject({ (remoteObj) -> Void in
                    remoteObj.pinInBackgroundWithBlock { (success, error) -> Void in
                        self.sharedObject = remoteObj
                    }
                })
            }
        }
    }
    
    func getRemoteSharedObject (completion:(PFObject)->Void) {
        var query = PFQuery(className:"SharedObject")
        query.getFirstObjectInBackgroundWithBlock { (obj, error) -> Void in
            if obj != nil {
                completion(obj!)
            }
            else {
                var o = PFObject(className:"SharedObject")
                o["myProp"] = 0
                o.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if (success) {
                        if (success) {
                            completion(o)
                        }
                    }
                    
                })
            }
        }
    }
    
    func getLocalSharedObject (completion:(PFObject?)->Void) {
        var query = PFQuery(className:"SharedObject")
        query.fromLocalDatastore()
        query.getFirstObjectInBackgroundWithBlock { (obj, error) -> Void in
            completion(obj)
        }
    }
    
    @IBAction func pinLocally(sender: AnyObject) {
        SVProgressHUD.showInfoWithStatus("Pinning", maskType: .Gradient)
        self.sharedObject.pinInBackgroundWithBlock { (success, error) -> Void in
            if (success) {
                SVProgressHUD.showSuccessWithStatus("")
            }
            else {
                SVProgressHUD.showErrorWithStatus("\(error?.localizedDescription)")
            }
        }
        
    }
    
    @IBAction func updateFromServer(sender: AnyObject) {
        SVProgressHUD.showInfoWithStatus("Updating", maskType: .Gradient)
        self.getRemoteSharedObject { (remoteObj) -> Void in
            let v = remoteObj["myProp"] as! Double
            self.sharedObject["myProp"] = v
            self.sharedObject.pinInBackgroundWithBlock({ (success, error) -> Void in
                self.refreshLabel()
                
                if (success) {
                    SVProgressHUD.showSuccessWithStatus("Value from Server: \(v)")
                }
                else {
                    SVProgressHUD.showErrorWithStatus("\(error)")
                }
            })
        }
    }
    
    
    @IBAction func savePinnedToServer(sender: AnyObject) {
        SVProgressHUD.showInfoWithStatus("Saving", maskType: .Gradient)
        self.sharedObject.saveInBackgroundWithBlock { (success, error) -> Void in
            if (success) {
                SVProgressHUD.showSuccessWithStatus("")
            }
            else {
                SVProgressHUD.showErrorWithStatus("\(error)")
            }
        }
        
    }
    

}

