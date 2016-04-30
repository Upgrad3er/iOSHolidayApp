//
//  MemoryController.swift
//  Project
//
//  Created by Axel Nyberg on 03/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//
import MobileCoreServices
import UIKit
import MapKit
import AVKit
import AVFoundation

class MemoryController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var tableData = [String]()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var placelabel: UILabel!
    @IBOutlet var timelabel: UILabel!
    @IBOutlet var positionlabel: UILabel!
    @IBOutlet var descriptionlabel: UILabel!
    @IBOutlet var memName: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    let imagePicker = UIImagePickerController()
    var jsonArray:[JSON] = [] // is used if more information about a json object is needed in a function that doesn't have that information 
    var mediaArray:[AnyObject] = [] // used to save images atm, could be used to save videos and sound if it would be implemented but it wont :D
    @IBOutlet var indicatorView: UIView! // Just to make it more sexy while loading media, dissapears when the media is loaded
    @IBOutlet var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    @IBOutlet var indicator: UIActivityIndicatorView! // animated untill indicatorview dissaperas and then this one also dissapears
    var mediaIndex: Int?
    let playImage = UIImage(named: "PlayIcon")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.hidden = true
        tableView.rowHeight = 250
        imagePicker.delegate = self
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer()) // So the slide menu works, not our work
    
       
       
        
        
        
   
        // load and write info about the current memory
        Apiconnect.getMemory(GlobalVariables.Variables.currentMemid, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                //print(result)
              //  var time = String(result["time"])
               // time = time[Range(start: time.startIndex, end: time.endIndex.advancedBy(-2))] + ":" + time[Range(start: time.startIndex.advancedBy(2), end: time.endIndex)]
                
              
                self.placelabel.text = String(result["place"])
                self.timelabel.text = "13:40"
                self.positionlabel.text = String(result["position"]["latitude"]) + "," + String(result["position"]["longitude"])
                self.memName.title = String(result["title"])
                self.descriptionlabel.text = String(result["description"])
                
                if(String(result["position"]["latitude"]) != String(0)){
                self.mapView.hidden = false
                let initialLocation = CLLocation(latitude: Double(String(result["position"]["latitude"]))!, longitude: Double(String(result["position"]["longitude"]))!)
                self.centerMapOnLocation(initialLocation)
                let pinCordinate = CLLocationCoordinate2D(latitude: Double(String(result["position"]["latitude"]))!, longitude: Double(String(result["position"]["longitude"]))!)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = pinCordinate
                dropPin.title = ""
                self.mapView.addAnnotation(dropPin)
                }
            }
        })
        
        // Fills the tabledata with the url of a media and also fills the mediaarray with relevant media.
        Apiconnect.getMediaList({result -> Void in dispatch_async(dispatch_get_main_queue()){
            
            for var index = 0; index < result.count; ++index {
                self.jsonArray.append(result[index])
                self.tableData.append(String(result[index]["fileurl"]))
                let mediaurl = NSURL(string: String(result[index]["fileurl"]))
                var stringurl = String(result[index]["fileurl"])
                stringurl = stringurl[Range(start: stringurl.endIndex.advancedBy(-3), end: stringurl.endIndex)]
  
                if(String(result[index]["container"]).rangeOfString("image") != nil){
                    self.mediaArray.append(NSData(contentsOfURL: mediaurl!)!)
                    //print(self.mediaArray.last)
                }
                else{
                    
                    self.mediaArray.append("swag") // need to have correct index in other functions
                }
            }
            self.indicatorView.hidden = true
            self.indicator.hidden = true
            self.tableView.reloadData()
            }})

        


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
      
    }

    
    func tableView(tableView: UITableView!,
    cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:"cell")
    
        if((String(jsonArray[indexPath.row]["container"]).rangeOfString("image")) != nil){
            cell.textLabel?.text = tableData[indexPath.row]
            cell.textLabel?.hidden = true
            cell.imageView?.image = UIImage(data: (mediaArray[indexPath.row]) as! NSData)
        }
        //the commented section here is for video and sound
         else if((String(jsonArray[indexPath.row]["container"]).rangeOfString("video")) != nil)
        {
            cell.textLabel?.text = tableData[indexPath.row]
            cell.textLabel?.hidden = true
            cell.imageView?.image = playImage
        }
        else if((String(jsonArray[indexPath.row]["container"]).rangeOfString("audio")) != nil)
        {
            cell.textLabel?.text = tableData[indexPath.row]
            cell.textLabel?.hidden = true
            cell.imageView?.image = playImage
        }
        else{
            cell.textLabel?.text = tableData[indexPath.row]
        }
    return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        
        return self.tableData.count;
    }
    
    // if clicked on a row, it will go the the link that is written in the cell, opens in safari
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            print("Clicked: \(cell.textLabel?.text)")
            let url = NSURL(string: (cell.textLabel?.text)!)
            
            if((String(jsonArray[indexPath.row]["container"]).rangeOfString("video")) != nil){
                let playerController = AVPlayerViewController()
                playerController.player = AVPlayer(URL: url!)
                self.presentViewController(playerController, animated: true, completion: nil)
                playerController.view.frame = self.view.frame
            }
            else if((String(jsonArray[indexPath.row]["container"]).rangeOfString("audio")) != nil){
                let playerController = AVPlayerViewController()
                playerController.player = AVPlayer(URL: url!)
                self.presentViewController(playerController, animated: true, completion: nil)
                playerController.view.frame = self.view.frame
            }
            else{
            UIApplication.sharedApplication().openURL(url!)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // this function check wich was the last view and if button pressed it will go back to thatone (same for every controller)
    @IBAction func Recent(sender: UIBarButtonItem) {
        
        if(GlobalVariables.Variables.RecentView.last == "Vacation"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("VacationController") as! VacationController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else if(GlobalVariables.Variables.RecentView.last == "Flow"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("FlowController") as! FlowController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else if(GlobalVariables.Variables.RecentView.last == "SearchMemory"){
            GlobalVariables.Variables.RecentView.removeLast()
            print(GlobalVariables.Variables.RecentView)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("SearchMemoryController") as! SearchMemoryController
            self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
        else{
            // let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("AddMediaController") as! AddMediaController
            // self.revealViewController().pushFrontViewController(nextViewController, animated: true)
        }
    }
 
   // opens photo gallery so that a user can choose video or sound, made just for fun and isnt used to anything
    @IBAction func upload(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeAudio as String]
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    // if a user click on video or image in imagepicker then it will be saved to data, this isn't used to anything thought
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //var data: UIImage?
        if ((info[UIImagePickerControllerOriginalImage] as? UIImage) != nil) {
          //  data = pickedata
        }
        dismissViewControllerAnimated(true, completion: nil)
        
        let mediatype = info[UIImagePickerControllerMediaType]! as! String
        
        if(mediatype == "public.movie")
        {
            print(mediatype)
            
        }
        else if(mediatype == "public.image")
        {
            print(mediatype)
        }
        else if(mediatype == "public.audio"){
            
            print(mediatype)
        }
       
        
    }
    
}

