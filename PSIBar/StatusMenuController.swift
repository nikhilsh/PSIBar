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
    var currentStatusLevel = ""
    
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
        
        dispatch_after(60,  dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "triggerUpdate", name: NSApplicationDidBecomeActiveNotification, object: nil)
        }
    }
    
    func triggerUpdate() {
        let getPSIData = PSIWeatherAPI()
        getPSIData.getPSIData(self.resultHandler)
    }
    
    func resultHandler(psi:NSString!) {
        statusItem.title = psi as String
        let psiValue:Int? = Int(psi as String)
        createNotificationWithPSI(psiValue!)
        
    }
    
    func createNotificationWithPSI(psi: Int) {
        let notification:NSUserNotification = NSUserNotification()
        if (psi<50) {
            if (currentStatusLevel == "good") {
                return
            }
            notification.title = "Good - " + String(psi)
            notification.subtitle = "The PSI is within the good range"
            notification.informativeText = "Normal activities! :)"
            currentStatusLevel = "good"
        }
        else if (psi>50 && psi<100) {
            if (currentStatusLevel == "moderate") {
                return
            }
            notification.title = "Moderate - " + String(psi)
            notification.subtitle = "The PSI is within the moderate range"
            notification.informativeText = "Normal activities."
            currentStatusLevel = "moderate"
        }
        else if (psi>100 && psi<200) {
            if (currentStatusLevel == "unhealthy") {
                return
            }
            notification.title = "Unhealthy - " + String(psi)
            notification.subtitle = "The PSI is within the unhealthy range"
            notification.informativeText = "Reduce prolonged or strenuous outdoor physical exertion"
            currentStatusLevel = "unhealthy"
        }
        else if (psi>201 && psi<300) {
            if (currentStatusLevel == "veryunhealthy") {
                return
            }
            notification.title = "Very Unhealthy - " + String(psi)
            notification.subtitle = "The PSI is within the very unhealthy range"
            notification.informativeText = "Avoid prolonged or strenuous outdoor physical exertion"
            currentStatusLevel = "veryunhealthy"
        }
        else {
            if (currentStatusLevel == "hazardous") {
                return
            }
            notification.title = "Hazardous - " + String(psi)
            notification.subtitle = "The PSI is within the hazardous range"
            notification.informativeText = "Minimise outdoor activity"
            currentStatusLevel = "hazardous"
        }
        
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
 
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSApplication.sharedApplication().terminate(self)
    }
}
