//
//  StatusMenuController.swift
//  PSIBar
//
//  Created by Nikhil Sharma on 25/9/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    var timer: dispatch_source_t!
    
    func startTimer() {
        let queue = dispatch_queue_create("com.domain.app.timer", nil)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1200 * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
        dispatch_source_set_event_handler(timer) {
            let getPSIData = PSIWeatherAPI()
            getPSIData.getPSIData(self.resultHandler)
            NSLog("updating")
        }
        dispatch_resume(timer)
    }
    
    func stopTimer() {
        dispatch_source_cancel(timer)
        timer = nil
    }

    override func awakeFromNib() {
        let icon = NSImage(named: "icon-haze")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        let getPSIData = PSIWeatherAPI()
        getPSIData.getPSIData(self.resultHandler)
        
        startTimer()
    }
    
    func resultHandler(psi:NSString!)
    {
        statusItem.title = psi as String
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
