//
//  Flow.swift
//  Project
//
//  Created by Axel Nyberg on 30/10/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class FlowController: UIViewController{
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

    override func viewDidLoad() {
        Apiconnect.loadData()
        GlobalVariables.Variables.RecentView = [] // resets this array becouse it should be nil on this viewcontroller
        
        //changes to logincontroller if no currentuser is signed in
        if(GlobalVariables.Variables.currentuser == nil){
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else{
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        }
    
    // shows seachmemorycontroller
    @IBAction func searchmemory(sender: UIBarButtonItem) {
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("SearchMemoryController") as! SearchMemoryController
        GlobalVariables.Variables.RecentView.append("Flow")
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)
    }
}