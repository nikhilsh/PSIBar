//
//  AppDelegate.swift
//  PSIBar
//
//  Created by Nikhil Sharma on 25/9/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true ])
        Fabric.with([Crashlytics.self()])
        
        NSUserNotificationCenter.default.delegate = self
    }

//    func applicationWillTerminate(aNotification: NSNotification) {
//        // Insert code here to tear down your application
//    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

}

