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
    let nowCaseURL = "http://www.nea.gov.sg/api/WebAPI?dataset=nowcast"
    
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

}

