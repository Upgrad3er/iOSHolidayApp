//
//  CreateMemory.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit
import CoreLocation

class CreateMemoryController: UIViewController, CLLocationManagerDelegate{

    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var titleText: UITextField!
    @IBOutlet var placeText: UITextField!
    @IBOutlet var descriptionText: UITextView!
    var locationManager: CLLocationManager!
    var locationAccess: Bool?
    var keyBoardOnScreen: Bool? = false
   

    // in this view the viewdidload will ask premission to use location, if not the location will be set to 0,0, asks only one time after user need to change it in iphone settings
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
     
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
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            locationAccess = true
        }
        else{
            locationAccess = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // see memorycontroller
    @IBAction func Recent(sender: UIBarButtonItem) {
        
        if(GlobalVariables.Variables.RecentView.last == "Vacation"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("VacationController") as! VacationController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else{
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
        }
    }
    // calls api with new memoryinfo and checks location and currenttime if possible
    @IBAction func createMemory(sender: AnyObject) {
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let DateInFormat:String? = dateFormatter.stringFromDate(todaysDate)
        var latitude: String? = ""
        var longitude: String? = ""
        print(DateInFormat!)
        if(locationAccess == true){
            print(locationManager.location?.coordinate.longitude)
            longitude = String(locationManager.location!.coordinate.longitude)
            latitude = String(locationManager.location!.coordinate.latitude)
        }
        
        Apiconnect.newMemory(GlobalVariables.Variables.currentVacid!, title: titleText.text!, description: descriptionText.text!, place: placeText.text!, time: DateInFormat!, posLong: longitude!, posLat: latitude!, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                
                let alert = UIAlertController(title: "Succces", message: "Memory succefully created.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
                alert.addAction(action)
                
                print(GlobalVariables.Variables.RecentView.last)
                if(GlobalVariables.Variables.RecentView.last == "Vacation"){
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
   

}