//
//  CreateVacation.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class CreateVacationController: UIViewController{
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var titleText: UITextField!
    @IBOutlet var placeText: UITextField!
    @IBOutlet var startText: UITextField!
    @IBOutlet var endText: UITextField!
    @IBOutlet var descriptionText: UITextView!
    var keyBoardOnScreen: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer()) // see memorycontroller
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

    // see memorycontroller
    @IBAction func Recent(sender: UIBarButtonItem) {
        
        if(GlobalVariables.Variables.RecentView.last == "Profile"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else{
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            //let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("AddMediaController") as! AddMediaController
            //self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
    }
    
    // shows viewcontroller for addvacation
    @IBAction func addVacation(sender: AnyObject) {
        print(startText.text!)
        Apiconnect.newVacation(titleText.text!, description: descriptionText.text!, start: startText.text!, end: endText.text!, place: placeText.text!, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                
                let alert = UIAlertController(title: "Succces", message: "Vacation succefully created.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
                alert.addAction(action)
                
                if(GlobalVariables.Variables.RecentView.last == "Profile"){
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
}