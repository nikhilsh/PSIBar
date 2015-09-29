//
//  PSIWeatherAPI.swift
//  PSIBar
//
//  Created by Nikhil Sharma on 25/9/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Foundation
import Alamofire

class PSIWeatherAPI {
    let psiBaseURL = "http://www.nea.gov.sg/api/WebAPI?dataset=psi_update"
    let forecastURL = "http://www.nea.gov.sg/api/WebAPI?dataset=12hrs_forecast"
    
    func getPSIData(completionHandler: ((NSString) -> Void)?) {
        Alamofire.request(.GET, psiBaseURL, parameters: ["keyref" : kAPIKey])
            .response { request, response, data, error in
                if let statusCode = response?.statusCode {
                    if statusCode == 200 {
                        let xml = SWXMLHash.parse(data!)
                        let psi = (xml["channel"]["item"]["region"][1]["record"][0]["reading"][1].element?.attributes["value"])!
                        completionHandler?(psi)
                    }
                }
            }
    }
    
    func getForecastData(completionHandler: (([NSString]) -> Void)?) {
        Alamofire.request(.GET, forecastURL, parameters: ["keyref" : kAPIKey])
            .response { request, response, data, error in
                if let statusCode = response?.statusCode {
                    if statusCode == 200 {
                        let xml = SWXMLHash.parse(data!)
                        let forecast = (xml["channel"]["item"]["forecast"].element?.text)!
                        let tempHigh = (xml["channel"]["item"]["temperature"].element?.attributes["high"])!
                        let tempLow = (xml["channel"]["item"]["temperature"].element?.attributes["low"])!
                        completionHandler?([forecast, tempHigh, tempLow])
                    }
                }
        }
    }
    
    func getDetailedPSIData(completionHandler: (([NSString], [NSString]) -> Void)?) {
        Alamofire.request(.GET, psiBaseURL, parameters: ["keyref" : kAPIKey])
            .response { request, response, data, error in
                if let statusCode = response?.statusCode {
                    if statusCode == 200 {
                        let xml = SWXMLHash.parse(data!)
                        let longPSI = (xml["channel"]["item"]["region"][1]["record"][0]["reading"][0].element?.attributes["value"])!
                        let northPSI = (xml["channel"]["item"]["region"][0]["record"][0]["reading"][1].element?.attributes["value"])!
                        let centralPSI = (xml["channel"]["item"]["region"][2]["record"][0]["reading"][1].element?.attributes["value"])!
                        let eastPSI = (xml["channel"]["item"]["region"][3]["record"][0]["reading"][1].element?.attributes["value"])!
                        let westPSI = (xml["channel"]["item"]["region"][4]["record"][0]["reading"][1].element?.attributes["value"])!
                        let southPSI = (xml["channel"]["item"]["region"][5]["record"][0]["reading"][1].element?.attributes["value"])!
                        completionHandler?([longPSI, northPSI, centralPSI, eastPSI, westPSI, southPSI], ["24 Hour PSI - ", "North PSI - ", "Central PSI - ", "East PSI - ", "West PSI - ", "South PSI - "])
                    }
                }
        }
    }

}

enum PSILevel {
    case Good
    case Moderate
    case Unhealthy
    case VeryUnhealthy
    case Hazardous
    
    init(_ psi: UInt) {
        switch psi {
        case 0..<50:
            self = .Good
        case 50..<100:
            self = .Moderate
        case 100..<200:
            self = .Unhealthy
        case 200..<300:
            self = .VeryUnhealthy
        default:
            self = .Hazardous
        }
    }
    
    var title: String {
        switch self {
        case .Good:
            return "Good"
        case .Moderate:
            return "Moderate"
        case .Unhealthy:
            return "Unhealthy"
        case .VeryUnhealthy:
            return "Very Unhealthy"
        case .Hazardous:
            return "Hazardous"
        }
    }
    
    var subtitle: String {
        switch self {
        case .Good:
            return "The PSI is within the good range"
        case .Moderate:
            return "The PSI is within the moderate range"
        case .Unhealthy:
            return "The PSI is within the unhealthy range"
        case .VeryUnhealthy:
            return "The PSI is within the very unhealthy range"
        case .Hazardous:
            return "The PSI is within the hazardous range"
        }
    }
    
    var informativeText: String {
        switch self {
        case .Good:
            return "You can resume normal activities! :)"
        case .Moderate:
            return "You can resume normal activities, according to NEA"
        case .Unhealthy:
            return "Reduce prolonged or strenuous outdoor physical exertion"
        case .VeryUnhealthy:
            return "Avoid prolonged or strenuous outdoor physical exertion"
        case .Hazardous:
            return "Minimise outdoor activity"
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


