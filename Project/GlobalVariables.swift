//
//  OrientationArray.swift
//  Project
//
//  Created by Axel Nyberg on 06/11/15.
//  Copyright © 2015 Axel Nyberg. All rights reserved.
//

import Foundation

class GlobalVariables{

    
    struct Variables {
        static var currentuser: CurrentUser! // used to the who is logged in
        static var RecentView:[String] = [] // remembers the last viewcontroller so the orientation is corret, this should not work like this becouse a similar function in the viewstack works the sameway but we didnt succeed to make that work. this may be a bad solving.
        static var currentProfile: String? // If its a friendsprofile or the currentusers profile, becouse its the same viewcontroller that shows profiles
        static var currentVacid: String? // Wich vacation that is handled in some scenarios
        static var currentMemid: String? // wich memory that is handled in some scenarios
    }

}