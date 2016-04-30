//
//  BackTableVC.swift
//  Project
//
//  Created by Axel Nyberg on 30/10/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit
// not explained cus its not our work 
class BackTableVC: UITableViewController{
    
    var TableArray = [String]()
   
 
    @IBOutlet var tableViewu: UITableView!
    
    override func viewDidLoad() {
        TableArray = ["Flow", "Friends","Profile", "Logout"]
        print("god")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableArray[indexPath.row], forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[indexPath.row]
        
        return cell
        
    }
    
    
    @IBAction func resetCurrentProfile(sender: UIButton) {
     
        GlobalVariables.Variables.RecentView = []
        let rowToSelect:NSIndexPath = NSIndexPath(forRow: 2, inSection: 0);
        self.tableViewu.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None)
        GlobalVariables.Variables.currentProfile = ""
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)
    }
  
    


}