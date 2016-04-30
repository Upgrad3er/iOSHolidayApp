//
//  MemoryController.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class VacationController: UIViewController{
    
    var tableData = [String]()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var place: UILabel!
    @IBOutlet var start: UILabel!
    @IBOutlet var descriptiontext: UILabel!
    @IBOutlet var vacName: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    var jsonArray:[JSON] = []// is used if more information about a json object is needed in a function that doesn't have that information 
   
 


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // writes out the information about curret vacation
        Apiconnect.getVacation(GlobalVariables.Variables.currentVacid, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                self.place.text = String(result["place"])
                self.start.text = String(result["start"]) + "-" + String(result["end"])
                print(result["start"])
                
                self.vacName.title = String(result["title"])
                self.descriptiontext.text = String(result["description"])
            }
        })
        // fills tabledata with name of every memory for the current vacation
        Apiconnect.getMemoryList({result -> Void in dispatch_async(dispatch_get_main_queue()){
            
            for var index = 0; index < result.count; ++index {
                self.jsonArray.append(result[index])
                self.tableData.append(String(result[index]["title"]))
                
            }
            print(self.tableData)
            self.tableView.reloadData()
            }})

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //changes the text for every cell with info from tabledata
    func tableView(tableView: UITableView!,
        cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:"cell")
        cell.textLabel?.text = tableData[indexPath.row]
        
        return cell
    }
    
    //counts tabledata so that it's known how many cells there should be
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.tableData.count;
    }
    //if a row gets selected it will go to memorycontroller and also change currentmemID to the one that is pressed and then show it in memorycontroller
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if (tableView.cellForRowAtIndexPath(indexPath) != nil) {
            GlobalVariables.Variables.currentMemid = String(jsonArray[indexPath.row]["id"])
            
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("MemoryController") as! MemoryController
            GlobalVariables.Variables.RecentView.append("Vacation")
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else {
            print("something went wrong")
        }
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // See memorycontroller
    @IBAction func Recent(sender: UIBarButtonItem) {
        
        if(GlobalVariables.Variables.RecentView.last == "Profile"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
            
        }
        else if(GlobalVariables.Variables.RecentView.last == "Flow"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("FlowController") as! FlowController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else{
            // let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("AddMediaController") as! AddMediaController
            // self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }

    }
    // changes view to CreateMemory
    @IBAction func addmemory(sender: UIBarButtonItem) {
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("CreateMemoryController") as! CreateMemoryController
        GlobalVariables.Variables.RecentView.append("Vacation")
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)

    }
    
    
}

