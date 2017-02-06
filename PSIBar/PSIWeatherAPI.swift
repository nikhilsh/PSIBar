//
//  PSIWeatherAPI.swift
//  PSIBar
//
//  Created by Nikhil Sharma on 25/9/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class PSIWeatherAPI {
    let pmBaseURL = "http://api.nea.gov.sg/api/WebAPI/?dataset=pm2.5_update&keyref=" + kAPIKey
    let psiBaseURL = "http://api.nea.gov.sg/api/WebAPI/?dataset=psi_update&keyref=" + kAPIKey
    let forecastURL = "http://api.nea.gov.sg/api/WebAPI?dataset=12hrs_forecast&keyref=" + kAPIKey
    
    func getPSIData(_ completionHandler: ((String) -> Void)?) {
        Alamofire.request(pmBaseURL).responseData { response in
            debugPrint("All Response Info: \(response)")
            switch response.result {
            case .success:
                let xml = SWXMLHash.parse(response.data!)
                let psi = (xml["channel"]["item"]["region"][1]["record"][0]["reading"].element?.attribute(by: "value"))!
                completionHandler?(psi.text)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func get24hPSIData(_ completionHandler: ((String) -> Void)?) {
        Alamofire.request(psiBaseURL).responseData { response in
            debugPrint("All Response Info: \(response)")
            switch response.result {
            case .success:
                let xml = SWXMLHash.parse(response.data!)
                let longPSI = (xml["channel"]["item"]["region"][1]["record"][0]["reading"][0].element?.attribute(by: "value"))!
                completionHandler?(longPSI.text)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getForecastData(_ completionHandler: (([String]) -> Void)?) {
        Alamofire.request(forecastURL).responseData { response in
            debugPrint("All Response Info: \(response)")
            switch response.result {
            case .success:
                let xml = SWXMLHash.parse(response.data!)
                let forecast = (xml["channel"]["item"]["forecast"].element?.text)!
                let temperatures = (xml["channel"]["item"]["temperature"].element?.allAttributes)!
                completionHandler?([forecast, (temperatures["high"]?.text)!, (temperatures["low"]?.text)!])
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func getDetailedPSIData(_ completionHandler: (([String], [String]) -> Void)?) {
        Alamofire.request(pmBaseURL).responseData { response in
            debugPrint("All Response Info: \(response)")
            switch response.result {
            case .success:
                let xml = SWXMLHash.parse(response.data!)
                let northPSI = (xml["channel"]["item"]["region"][0]["record"][0]["reading"].element?.attribute(by: "value"))!
                let centralPSI = (xml["channel"]["item"]["region"][1]["record"][0]["reading"].element?.attribute(by: "value"))!
                let eastPSI = (xml["channel"]["item"]["region"][2]["record"][0]["reading"].element?.attribute(by: "value"))!
                let westPSI = (xml["channel"]["item"]["region"][3]["record"][0]["reading"].element?.attribute(by: "value"))!
                let southPSI = (xml["channel"]["item"]["region"][4]["record"][0]["reading"].element?.attribute(by: "value"))!
                completionHandler?([northPSI.text, centralPSI.text, eastPSI.text, westPSI.text, southPSI.text], ["North PM2.5 - ", "Central PM2.5 - ", "East PM2.5 - ", "West PM2.5 - ", "South PM2.5 - "])
            case .failure(let error):
                print(error)
            }
        }
    }
}

enum PSILevel {
    case normal
    case elevated
    case high
    case veryHigh
    
    init(_ psi: UInt) {
        switch psi {
        case 0..<56:
            self = .normal
        case 56..<151:
            self = .elevated
        case 151..<251:
            self = .high
        default:
            self = .veryHigh
        }
    }
    
    var title: String {
        switch self {
        case .normal:
            return "Normal"
        case .elevated:
            return "Elevated"
        case .high:
            return "High"
        case .veryHigh:
            return "Very High"
        }
    }
    
    var subtitle: String {
        switch self {
        case .normal:
            return "The PM2.5 is within the normal range"
        case .elevated:
            return "The PM2.5 is within the elevated range"
        case .high:
            return "The PM2.5 is within the high range"
        case .veryHigh:
            return "The PM2.5 is within the very high range"
        }
    }
    
    var informativeText: String {
        switch self {
        case .normal:
            return "You can resume normal activities! :)"
        case .elevated:
            return "Reduce prolonged or strenuous outdoor physical exertion"
        case .high:
            return "Minimise outdoor activity"
        case .veryHigh:
            return "Avoid outdoor activity"
        }
    }
}

extension PSILevel {
    func getNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = informativeText
        return notification
    }
}


