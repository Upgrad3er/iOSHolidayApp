//
//  MemoryController.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class FriendsController: UIViewController{
    
    @IBOutlet var tableView: UITableView!
    var tableData = [String]()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
 
        // fills tabledata with friends from api
        Apiconnect.getFriendList(GlobalVariables.Variables.currentuser.username!, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){

                for var index = 0; index < result.count; ++index {
                    self.tableData.append(String(result[index]["username"]))
                }
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // fills every cell with name of friend of currentuser
    func tableView(tableView: UITableView!,
        cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:"cell")
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.tableData.count;
    }
    
    //open profilecontroller of friend clicked and set globalvariables
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
            GlobalVariables.Variables.currentProfile = (cell.textLabel?.text)!
            GlobalVariables.Variables.RecentView.append("Friends")
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else {
            print("something went wrong")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    // opens view for addfriend when button is clicked 
    @IBAction func addfriend(sender: UIBarButtonItem) {
        GlobalVariables.Variables.RecentView.append("Friends")
        print(GlobalVariables.Variables.RecentView)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("NewFriendController") as! NewFriendController
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)
    }
    
}

