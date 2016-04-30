//
//  CreateAccountController.swift
//  Project
//
//  Created by Axel Nyberg on 02/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class CreateAccountController: UIViewController{
    
    @IBOutlet var username: UITextField!
    @IBOutlet var firstname: UITextField!
    @IBOutlet var lastname: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var rpassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // calls the api and and creates the account when button pressed, shows failure messages if something is incorrect
    @IBAction func Create(sender: UIButton) {
        Apiconnect.createaccount(username.text!, password: password.text!, confirmpassword: rpassword.text!, email: email.text!, firstname: firstname.text!, lastname: lastname.text!, completion: {result -> Void in dispatch_async(dispatch_get_main_queue()){print(result)
            
            if(result == nil){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginController")
            self.presentViewController(nextViewController, animated:true, completion:nil)
            }
            else{
                let alert = UIAlertController(title: "Error", message: String(result["modelState"]), preferredStyle: .Alert)
                let action = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            }
        })
    }   
}