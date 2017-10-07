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
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    var timer: Timer = Timer()
    var currentPSI = PSILevel(99)
    var currentStatusLevel = PSILevel.normal
    let getPSIData = PSIWeatherAPI()
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.triggerUpdate), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "icon-haze")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        determineStateOfLoginButton()
        triggerUpdate()
        startTimer()
        
        delayWithSeconds(5) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.triggerUpdate), name: NSNotification.Name.NSApplicationDidBecomeActive, object: nil)
        }
        
        closeHelperApp()
    }
    
    func triggerUpdate() {
        getPSIData.getPSIData(self.resultHandler)
        getDetailedPSIValues()
    }
    
    func resultHandler(_ psi: String!) {
        DispatchQueue.main.async {
            self.statusItem.title = psi as String
        }
        let psiValue:UInt? = UInt(psi as String)
        self.currentPSI = PSILevel.init(psiValue!)
        if (self.currentPSI.hashValue != self.currentStatusLevel.hashValue) {
            self.createNotificationWithPSI()
        }
    }
    
    func createNotificationWithPSI() {
        currentStatusLevel = currentPSI
        let notification = currentPSI.getNotification()
        let item = self.statusMenu.item(at: 0)
        item?.title = currentPSI.title.capitalized
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    @IBAction func didClickOnForecast(_ sender: NSMenuItem) {
        getPSIData.getForecastData { (weather: [String]) -> Void in
            self.dialogForecast(weather[0] as String, tempHigh: weather[1] as String, tempLow: weather[2] as String)
        }
    }
    
    func getDetailedPSIValues() {
        getPSIData.getDetailedPSIData { (psiData : [String], menuItemName : [String]) -> Void in
            for i in 0 ..< psiData.count {
                let item = self.statusMenu.item(at: i + 3)
                item?.title = (menuItemName[i] as String) + (psiData[i] as String)
            }
            let item = self.statusMenu.item(at: 0)
            item?.title = "PM2.5 Rating - " + self.currentPSI.title.capitalized
        }
        get24hPSIValue()
    }
    
    func get24hPSIValue() {
        getPSIData.get24hPSIData { (psi) in
            let item = self.statusMenu.item(at: 2)
            item?.title = "24 Hour PSI - " + psi
        }
    }
    
    func dialogForecast(_ forecast: String, tempHigh: String, tempLow: String) -> Void {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Twelve Hour Forecast by NEA"
        myPopup.informativeText = "The weather is forecasted to be: " + forecast + "\r\n\n" + "The temperature will be between " + tempLow + "and" + tempHigh + " Degrees Celsius."
        myPopup.alertStyle = .informational
        myPopup.addButton(withTitle: "Okay")
        myPopup.runModal()
    }
    
    func determineStateOfLoginButton() {
        let loginEnabled = UserDefaults.standard.bool(forKey: "LoginEnabled")
        loginButton.state = loginEnabled ? 1 : 0
    }
    
    func closeHelperApp () {
        var startedAtLogin = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == "sh.nikhil.PSIBar-helper" {
                startedAtLogin = true
            }
        }
        if startedAtLogin {
            let center = DistributedNotificationCenter.default()
            let notificationName = NSNotification.Name(rawValue: "killHelperAppPSIBar")
            center.post(name: notificationName, object: Bundle.main.bundleIdentifier)
        }
    }
    
    @IBAction func handleLaunchAtLoginButton(_ sender: AnyObject) {
        let loginEnabled = !UserDefaults.standard.bool(forKey: "LoginEnabled")
        loginButton.state = loginEnabled ? 1 : 0
        SMLoginItemSetEnabled("sh.nikhil.PSIBar-helper" as CFString, loginEnabled)
        UserDefaults.standard.set(loginEnabled as Bool, forKey: "LoginEnabled")
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSApplicationDidBecomeActive, object: nil)
        stopTimer()
        NSApplication.shared().terminate(self)
    }
}
