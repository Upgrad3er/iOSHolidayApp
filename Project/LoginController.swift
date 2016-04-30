//
//  LoginController.swift
//  Project
//
//  Created by Axel Nyberg on 01/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit


class LoginController: UIViewController{

    @IBOutlet var Username: UITextField!
    @IBOutlet var Password: UITextField!
    @IBOutlet var indicator1: UIActivityIndicatorView!
    var keyBoardOnScreen: Bool? = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalVariables.Variables.RecentView = []
        Apiconnect.deletecoredata()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if(keyBoardOnScreen == false){
                self.view.frame.origin.y -= keyboardSize.height
                keyBoardOnScreen = true;
            }
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if(keyBoardOnScreen == true){
            self.view.frame.origin.y += keyboardSize.height
            keyBoardOnScreen = false
            }
        }
    }

    // calls the api and tells the user if something went wrong else the user will be logged in and global currentuser will be set.
    @IBAction func Login() {
        indicator1.startAnimating()
            Apiconnect.getaccestoken(Username.text!, password: Password.text!, completion: {result -> Void in
                dispatch_async(dispatch_get_main_queue()){
            self.indicator1.stopAnimating()
            if(result["access_token"] == nil){
                
                let alert = UIAlertController(title: "Error", message: String(result["error_description"]), preferredStyle: .Alert)
                let action = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("Reveal")
                self.presentViewController(nextViewController, animated:true, completion:nil)
            }
        }
        })
    }
}