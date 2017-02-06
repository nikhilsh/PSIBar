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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "com.cubiclerebels.PSIBar"
        let running = NSWorkspace.shared().runningApplications
        var alreadyRunning = false
        
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }
        
        if !alreadyRunning {
            let center = DistributedNotificationCenter.default()
            center.addObserver(self, selector: #selector(terminate), name: NSNotification.Name(rawValue: "killHelperAppPSIBar"), object: mainAppIdentifier)
            
            let path = Bundle.main.bundlePath as String
            var pathURL = URL(string: path)
            pathURL?.deleteLastPathComponent()
            pathURL?.deleteLastPathComponent()
            pathURL?.deleteLastPathComponent()
            pathURL?.appendPathComponent("Products")
            pathURL?.appendPathComponent("Debug")
            pathURL?.appendPathComponent("PSIBar.app")
            
            NSWorkspace.shared().launchApplication((pathURL?.absoluteString)!)
        }
        else {
            self.terminate()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func terminate() {
        NSApp.terminate(nil)
    }


}

