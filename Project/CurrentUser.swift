//
//  CurrentUser.swift
//  Project
//
//  Created by Axel Nyberg on 07/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import Foundation
import CoreData

class CurrentUser:NSManagedObject{

    var username: String?
    var password: String?
    var requesttoken: String?

    
 
       init(uusername:String, ppassword:String, rrequestToken:String){
            self.username = uusername
            self.password = ppassword
            self.requesttoken = rrequestToken
        }

}