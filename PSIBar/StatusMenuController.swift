//
//  StatusMenuController.swift
//  PSIBar
//
//  Created by Nikhil Sharma on 25/9/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Cocoa
import ServiceManagement

class StatusMenuController: NSObject {

    @IBOutlet weak var loginButton: NSMenuItem!
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    var timer: dispatch_source_t!
    var currentPSI = PSILevel(99)
    var currentStatusLevel = PSILevel.Good
    let getPSIData = PSIWeatherAPI()
    
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
        
        determineStateOfLoginButton()
        triggerUpdate()
        startTimer()
        
        dispatch_after(60,  dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "triggerUpdate", name: NSApplicationDidBecomeActiveNotification, object: nil)
        }
        closeHelperApp()
    }
    
    func triggerUpdate() {
        getPSIData.getPSIData(self.resultHandler)
        getDetailedPSIValues()
    }
    
    func resultHandler(psi:NSString!) {
        statusItem.title = psi as String
        let psiValue:UInt? = UInt(psi as String)
        currentPSI = PSILevel.init(psiValue!)
        if (currentPSI.hashValue != currentStatusLevel.hashValue) {
            createNotificationWithPSI()
        }
    }
    
    func createNotificationWithPSI() {
        currentStatusLevel = currentPSI
        let notification = currentPSI.getNotification()
        let item = self.statusMenu.itemAtIndex(0)
        item?.title = currentPSI.title.capitalizedString
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    @IBAction func didClickOnForecast(sender: NSMenuItem) {
        getPSIData.getForecastData { (weather: [NSString]) -> Void in
            self.dialogForecast(weather[0] as String, tempHigh: weather[1] as String, tempLow: weather[2] as String)
        }
    }
    func getDetailedPSIValues() {
        getPSIData.getDetailedPSIData { (psiData : [NSString], menuItemName : [NSString]) -> Void in
            for var i = 0; i < psiData.count; i++ {
                let item = self.statusMenu.itemAtIndex(i + 2)
                item?.title = (menuItemName[i] as String) + (psiData[i] as String)
            }
            let item = self.statusMenu.itemAtIndex(0)
            item?.title = "PSI Rating - " + self.currentPSI.title.capitalizedString
        }
    }
    
    func dialogForecast(forecast: String, tempHigh: String, tempLow: String) -> Void {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Twelve Hour Forecast by NEA"
        myPopup.informativeText = "The weather is forecasted to be: " + forecast + "\r\n\n" + "The temperature will be between " + tempLow + "and" + tempHigh + " Degrees Celsius."
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("Okay")
        myPopup.runModal()
    }
    
    func determineStateOfLoginButton() {
        let loginEnabled = NSUserDefaults.standardUserDefaults().boolForKey("LoginEnabled")
        if (loginEnabled) {
            loginButton.state = 1
        }
        else {
            loginButton.state = 0
        }
    }
    
    func closeHelperApp () {
        var startedAtLogin = false
        for app in NSWorkspace.sharedWorkspace().runningApplications {
            if app.bundleIdentifier == "sh.nikhil.PSIBar-helper" {
                startedAtLogin = true
            }
        }
        if startedAtLogin {
            NSDistributedNotificationCenter.defaultCenter().postNotificationName("killHelperAppPSIBar", object: NSBundle.mainBundle().bundleIdentifier!)
        }
    }
    
    @IBAction func handleLaunchAtLoginButton(sender: AnyObject) {
        let loginEnabled = !NSUserDefaults.standardUserDefaults().boolForKey("LoginEnabled")
        if (loginEnabled) {
            loginButton.state = 1
        }
        else {
            loginButton.state = 0
        }
        SMLoginItemSetEnabled("sh.nikhil.PSIBar-helper" as CFString, loginEnabled)
        NSUserDefaults.standardUserDefaults().setBool(loginEnabled, forKey: "LoginEnabled")
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSApplicationDidBecomeActiveNotification, object: nil)
        stopTimer()
        NSApplication.sharedApplication().terminate(self)
    }
}
