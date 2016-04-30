//
//  Apiconnect.swift
//  Project
//
//  Created by Axel Nyberg on 06/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import Foundation
import CoreData

class Apiconnect{
    
   
    // saves name and pass to core data after logged in
    class func saveData(){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("UserData", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! UserData
        item.setValue(GlobalVariables.Variables.currentuser?.username, forKey: "userName")
        item.setValue(GlobalVariables.Variables.currentuser?.password, forKey: "password")
        
        do {
            try managedContext.save()
        } catch {
            fatalError(String(error))
        }
    }
    // load if coredata is not empty
    class func loadData(){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "UserData")
        let fetchResult = (try! managedContext.executeFetchRequest(fetchRequest)) as! [UserData]
        for item in fetchResult{
            GlobalVariables.Variables.currentuser = CurrentUser(uusername: item.userName!, ppassword: item.password!, rrequestToken: "yo")
            getAccessTokenWhenAlreadySignedIn()
            }
        }
    
    //Called when user press logout, delete all coredata in entity "userdata"
    class func deletecoredata(){
       
        let fetchRequest = NSFetchRequest(entityName: "UserData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        do {
            try managedContext.executeRequest(deleteRequest)
        } catch {
            fatalError(String(error))
        }
    }
    
   class func getAccessTokenWhenAlreadySignedIn(){
        
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "accept": "application/json",
            "cache-control": "no-cache",
        ]
        
        let postData = NSMutableData(data: "grant_type=password".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&username=\(GlobalVariables.Variables.currentuser.username!)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&password=\(GlobalVariables.Variables.currentuser.password!)".dataUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/token")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                if(json["access_token"] == nil){
                    print("error")
                }
                else{
                    GlobalVariables.Variables.currentuser.requesttoken = String(json["access_token"])
                }
                print((GlobalVariables.Variables.currentuser?.requesttoken!)!)
                print((GlobalVariables.Variables.currentuser?.username)!)
                print((GlobalVariables.Variables.currentuser?.password!)!)
            }
        })
        dataTask.resume()
    }
    
    //Get the acces token and send it back to LoginController or a error message
    class func getaccestoken(username:String!, password:String!, completion:(result:JSON) -> Void ){
        
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "accept": "application/json",
            "cache-control": "no-cache",
        ]
       
        let postData = NSMutableData(data: "grant_type=password".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&username=\(username)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/token")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                if(json["access_token"] != nil){
                GlobalVariables.Variables.currentuser = CurrentUser(uusername: username, ppassword: password, rrequestToken: String(json["access_token"]))
                }
                saveData()
                completion(result: json)
            }
        })
        dataTask.resume()
    }
    
    //Creates a user account and sends back the api result to CreateAccountController
    class func createaccount(username:String, password:String, confirmpassword:String, email:String, firstname:String, lastname:String, completion:(result:JSON) -> Void ){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        let parameters = [
            "username": username,
            "password": password,
            "confirmpassword":confirmpassword,
            "email": email,
            "firstname": firstname,
            "lastname": lastname
        ]
        
        do {
            let postData = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/accounts")!,
                cachePolicy: .UseProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.HTTPMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.HTTPBody = postData
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    //let httpResponse = response as? NSHTTPURLResponse
                    let json = JSON(data: data!)
                    completion(result: json)
                }
            })
            dataTask.resume()
        } catch{
            print(error)
        }
    }
    
    
    class func addfriend(friend:String, friendfirstname:String, friendlastname:String, friendemail:String,  completion:(result:JSON) -> Void){
        
    
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
           // "postman-token": "76db0285-93d9-ddef-df5e-eb72946f6278"
        ]
        
        
        let postData = NSMutableData(data: "username=\(friend)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&lastname=\(friendlastname)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&firstname=\(friendfirstname)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&email=\(friendemail)".dataUsingEncoding(NSUTF8StringEncoding)!)
        print(GlobalVariables.Variables.currentuser.username!)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/users/\(GlobalVariables.Variables.currentuser.username!)/friends")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                //let httpResponse = response as? NSHTTPURLResponse
                //print(httpResponse)
                let json = JSON(data: data!)
                completion(result: json)
            }
        })
        
        dataTask.resume()
        

        
                  }
    
    class func getuserinfo(username:String!, completion:(result:JSON) -> Void) {
        
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
            //"postman-token": "44637d1e-09b4-85c4-14e3-30579521277a"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/users/\(username)")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                completion(result: json)            }
        })
        
        dataTask.resume()
    }
    
    class func getFriendList(username: String!, completion:(result:JSON) -> Void) {
        
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
            "postman-token": "e7ed7bbb-8c28-4b3a-557b-718c29ac0f25"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/users/\(username)/friends")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)
            }
        })
        
        dataTask.resume()
    
        
    
    
    }
    
    class func newVacation(title: String!, description: String!, start: String!, end: String!, place: String!, completion:(result:JSON) -> Void){
    
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
           // "postman-token": "7e06010e-6ab0-f7ea-9fe5-969afe29950c"
        ]
        print(start)
        let postData = NSMutableData(data: "title=\(title)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&description=\(description)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start=\(start)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end=\(end)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&place=\(place)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/vacations")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)
            }
        })
        
        dataTask.resume()
    
    }
    
    class func getVacationList(completion:(result:JSON) -> Void){
        
       
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
            //"postman-token": "569e7b1b-5f6e-3722-16dd-50217a78859b"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/vacations")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
             print("FIRST?")
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                print(2)
                completion(result: json)
            }
        })
        
        dataTask.resume()
    
    }
    
    
    class func getVacation(id: String!, completion:(result:JSON) -> Void){
    
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
           // "postman-token": "fe6d6585-4325-13d4-8f91-5bc2a0db1958"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/vacations/\(id)")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)
            }
        })
        
        dataTask.resume()
    
    
    }
    
    class func newMemory(vacID: String!, title: String!, description: String!, place: String!, time: String!, posLong: String!, posLat: String!,completion:(result:JSON) -> Void)
    {
        print(time)
        print(vacID)
        let headers = [
            "content-type": "application/json",
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "accept": "application/json",
            "cache-control": "no-cache",
            "postman-token": "881dae4e-5ef6-41a8-4050-947079d1a6a4"
        ]
        let parameters = [
            "title": title,
            "description": description,
            "place": place,
            "time": time,
            "position": [
                "longitude": posLong,
                "latitude": posLat
            ]
        ]
        
        do{
            let postData = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])

        
            let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/vacations/\(vacID)/memories")!,
                cachePolicy: .UseProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.HTTPMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.HTTPBody = postData
        
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                //let httpResponse = response as? NSHTTPURLResponse
                let json = JSON(data: data!)
                completion(result: json)
            }
        })
        
        dataTask.resume()
        }
        catch{
            print(error)
        }
    
    
    
    }
    
    class func getMemoryList( completion:(result:JSON) -> Void) {
        
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
        //    "postman-token": "03b7acb3-27ef-b235-1bc2-2a63502dccff"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/vacations/\(GlobalVariables.Variables.currentVacid!)/memories")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                completion(result: json)
            }
        })
        
        dataTask.resume()
    }
    
    class func getMemory(memId: String!, completion:(result:JSON) -> Void){
    
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
          //  "postman-token": "d5b02a98-181a-82e4-9c99-43c0c79592a9"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/memories/\(memId)")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)

            }
        })
        
        dataTask.resume()
    
    }
    
    class func searchMemory(type: String!, query:String!, completion:(result:JSON) -> Void){
        
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "content-type": "application/json",
            "cache-control": "no-cache",
           // "postman-token": "7ad0d365-952f-2e5a-afb7-976208733d10"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/memories/search?type=\(type!)&q=\(query)")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)

            }
        })
        
        dataTask.resume()
    
    
    }
    
    class func uploadPicture(completion:(result:JSON)-> Void){
        
        let headers = [
          
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
            "postman-token": "0c4ec6c3-bd2c-8796-7a7f-81dfe985d8e0"
        ]
        let parameters = [
            [
                "content-type": "multipart/form-data; boundary=---011000010111000001101001",
                "name": "picture-file",
                "fileName": "/Users/axelnyberg/Desktop/Csbild.jpg"
            ]
        ]
        
        let boundary = "---011000010111000001101001"
        
        var body = ""
        let error: NSError? = nil
        do{
        for param in parameters {
            let paramName = param["name"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
               
                let fileContent = try String(contentsOfFile: filename, encoding: NSUTF8StringEncoding)
                if (error != nil) {
                    print(error)
                }
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                body += fileContent
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/memories/\(GlobalVariables.Variables.currentMemid!))/pictures?width=26&height=26")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
       // request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)
            }
        })
        
        dataTask.resume()
        }
        catch{
        print(error)
        }
        
        
        }
    
    class func uploadVideo(completion:(result:String)->Void)
    {
    
        completion(result: "the swag file has been uploaded")
    }
    
    class func uploadSound(completion:(result:String)->Void)
    {
        
        completion(result: "the swag file has been uploaded")
    }
    
    class func getMediaList(completion:(result:JSON)->Void){
    
        let headers = [
            "authorization": "bearer \(GlobalVariables.Variables.currentuser.requesttoken!)",
            "cache-control": "no-cache",
            "postman-token": "2c35ae26-447d-cb9f-0b29-39a3591c01e3"
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.abs-cloud.elasticbeanstalk.com/api/v1/memories/\(GlobalVariables.Variables.currentMemid!)/media-objects")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = JSON(data: data!)
                //print(json)
                completion(result: json)
            }
        })
        
        dataTask.resume()
        
    }
    
    
 
    
    

}