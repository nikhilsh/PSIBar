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
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 600 * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 10 mins, with leeway of 1 second
        dispatch_source_set_event_handler(timer) {
            self.triggerUpdate()
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
        
        triggerUpdate()
        startTimer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "triggerUpdate", name: NSApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func triggerUpdate() {
        let getPSIData = PSIWeatherAPI()
        getPSIData.getPSIData(self.resultHandler)
    }
    
    func resultHandler(psi:NSString!) {
        statusItem.title = psi as String
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSApplication.sharedApplication().terminate(self)
    }
}
