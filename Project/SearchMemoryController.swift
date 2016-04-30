//
//  MemoryController.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import UIKit

class SearchMemoryController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var jsonArray:[JSON] = []// is used if more information about a json object is needed in a function that doesn't have that information
    var searchActive : Bool = false
    var data = [String]()
    var filtered:[String] = []
    var resultFriend: JSON!
    
    //delegates tableview and searchbar so that the search function works
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
        searchMemory("title", query: searchBar.text!)
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchMemory("title", query: searchBar.text!)
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
    
    
    
    // if a memory is pressed memorycontroller will show this memory and the media
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
  
        if (tableView.cellForRowAtIndexPath(indexPath) != nil) {
            GlobalVariables.Variables.currentMemid = String(jsonArray[indexPath.row]["id"])
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("MemoryController") as! MemoryController
            GlobalVariables.Variables.RecentView.append("SearchMemory")
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else {
            print("something went wrong")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // get memories from the api
    func searchMemory(type: String!, query: String!){
        
        Apiconnect.searchMemory(type, query: query, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                self.data = []
                self.jsonArray = []
                if(result["message"] == nil){
                   
                    for var index = 0; index < result.count; ++index {
                        self.jsonArray.append(result[index])
                        self.data.append(String(result[index]["title"]))
                    }
                }
                else{
                    self.data = []
                    self.jsonArray = []
                }
                self.tableView.reloadData()
            }
        })
    }
    // see memorycontroller
    @IBAction func Recent(sender: UIBarButtonItem) {
        GlobalVariables.Variables.RecentView.removeLast()
        print(GlobalVariables.Variables.RecentView)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("FlowController") as! FlowController
        self.revealViewController().pushFrontViewController(nextViewController, animated: true)
    }
   
}

