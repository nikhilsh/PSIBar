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
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Fabric.with([Crashlytics.self()])
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

