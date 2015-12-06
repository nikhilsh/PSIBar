//
//  AppDelegate.swift
//  PSIBar-helper
//
//  Created by Nikhil Sharma on 24/11/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let mainAppIdentifier = "com.cubiclerebels.PSIBar"
        let running = NSWorkspace.sharedWorkspace().runningApplications
        var alreadyRunning = false
        
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }
        
        if !alreadyRunning {
            NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "terminate", name: "killHelperAppPSIBar", object: mainAppIdentifier)
            
            let path = NSBundle.mainBundle().bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("Products")
            components.append("Debug")
            components.append("PSIBar.app")
            
            let newPath = NSString.pathWithComponents(components)
            NSLog("PSIBar hlper" + newPath)
            NSWorkspace.sharedWorkspace().launchApplication(newPath)
        }
        else {
            self.terminate()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func terminate() {
        NSApp.terminate(nil)
    }


}

