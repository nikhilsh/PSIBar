//
//  PSIWeatherAPI.swift
//  PSIBar
//
//  Created by Nikhil Sharma on 25/9/15.
//  Copyright © 2015 The Cubiclerebels. All rights reserved.
//

import Foundation


class PSIWeatherAPI {
    //
    
    let psiBaseURL = "http://www.nea.gov.sg/api/WebAPI?dataset=psi_update&keyref=addyourkeyhere"
    let nowCaseURL = "http://www.nea.gov.sg/api/WebAPI?dataset=nowcast&keyref=addyourkeyhere"
    
    func getPSIData(completionHandler: ((NSString) -> Void)?) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: psiBaseURL)
        let task = session.dataTaskWithURL(url!) { data, response, error in
            let xml = SWXMLHash.parse(data!)
            let psi = (xml["channel"]["item"]["region"][1]["record"][0]["reading"][1].element?.attributes["value"])!
            NSLog(psi)
            completionHandler?(psi)
        }
        task.resume()
    }
}
