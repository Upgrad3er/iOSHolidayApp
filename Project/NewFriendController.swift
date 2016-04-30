//
//  NewFriendController.swift
//  Project
//
//  Created by Axel Nyberg on 06/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class NewFriendController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var searchActive : Bool = false
    var data = [String]()
    var filtered:[String] = []
    var resultFriend: JSON!
    
    // delegates so that the search will work
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        apiSearchUser(searchBar.text!)
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return data.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = data[indexPath.row];
        }
        return cell;
    }
    
    
    
    // if friend is clicked the friend will be added to currentuser friendlist
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            Apiconnect.addfriend(String(resultFriend["username"]), friendfirstname: String(resultFriend["firstname"]), friendlastname: String(resultFriend["lastname"]), friendemail: String(resultFriend["email"]), completion: {result -> Void in dispatch_async(dispatch_get_main_queue()){

                if(result == nil){
                    let alert = UIAlertController(title: "Succces", message: "\((cell.textLabel?.text!)!) has been added to your friendlist.", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "Error", message: "\((cell.textLabel?.text!)!) is already in your friendlist.", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                }})
        }
        else {
            print("something went wrong")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // get the friend that is searched for
    func apiSearchUser(friend: String!){
        
        Apiconnect.getuserinfo(friend, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                
                print(result)
                
                if(result["message"] == nil){
                    print(result["firstname"])
                    print(result["lastname"])
                    print(result["email"])
                    self.resultFriend = result
                    self.data = [friend]
                    self.tableView.reloadData()
                }
                else{
                    self.data = []
                }
            }
        })
    }
    // see memorycontroller
    @IBAction func Recent(sender: UIBarButtonItem) {
        GlobalVariables.Variables.RecentView.removeLast()
        print(GlobalVariables.Variables.RecentView)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("FriendsController") as! FriendsController
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)

    }
   


    

}
