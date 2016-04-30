//
//  MemoryController.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class ProfileController: UIViewController{
    @IBOutlet var userName: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var recentbtn: UIBarButtonItem!
    var tableData = [String]()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var jsonArray:[JSON] = []// is used if more information about a json object is needed in a function that doesn't have that information 
    @IBOutlet var firstName: UILabel!
    @IBOutlet var email: UILabel!
      
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        userName.title = GlobalVariables.Variables.currentuser.username! // the view gets the title of current user
        
        // if this viewcontroller is opened from friendlist the currentprofile variable will be set to that friend
        if(GlobalVariables.Variables.currentProfile!.isEmpty == true){
            GlobalVariables.Variables.currentProfile = GlobalVariables.Variables.currentuser.username!
        }
        // if this viewcontroller is opened from swipemenu then it is the currentprofile will be set to currentuser
        if(GlobalVariables.Variables.currentProfile == GlobalVariables.Variables.currentuser.username){
            recentbtn.enabled = false
            recentbtn.title = ""
        }
        
        
        userName.title = GlobalVariables.Variables.currentProfile
        // writes info about currentuser
        Apiconnect.getuserinfo(GlobalVariables.Variables.currentProfile, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                self.firstName.text = String(result["firstname"]) + " " + String(result["lastname"])
                self.email.text = String(result["email"])
            }
        })
        //Fills tabledata with currentusers vacations and also fills the jsonarray
        Apiconnect.getVacationList({result -> Void in dispatch_async(dispatch_get_main_queue()){

            for var index = 0; index < result.count; ++index {
                if(String(result[index]["user"]["username"]) == GlobalVariables.Variables.currentProfile){
                    self.jsonArray.append(result[index])
                    self.tableData.append(String(result[index]["title"]))
                }
            }
            self.tableView.reloadData()
        }})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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
    // changes to vacationscontroller and shows clicked vacation and sets currentVacid to that vacations.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if (tableView.cellForRowAtIndexPath(indexPath) != nil) {
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("VacationController") as! VacationController
            GlobalVariables.Variables.currentVacid = String(jsonArray[indexPath.row]["id"])
            print(GlobalVariables.Variables.currentVacid)
            GlobalVariables.Variables.RecentView.append("Profile")
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else {
            print("something went wrong")
        }
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // shows the addvacationscontroller, knows wich users profile that the vacation will be added to becouse of globalvariable "currentUser"
    @IBAction func addvacation(sender: UIBarButtonItem) {
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("CreateVacationController") as! CreateVacationController
        GlobalVariables.Variables.RecentView.append("Profile")
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)

    }

    // see memorycontroller
    @IBAction func Recent(sender: UIBarButtonItem) {
        if(GlobalVariables.Variables.RecentView.last == "Friends"){
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("FriendsController") as! FriendsController
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }

    }
}

