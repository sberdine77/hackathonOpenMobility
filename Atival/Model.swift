//
//  Model.swift
//  Atival
//
//  Created by Sávio Berdine on 03/02/19.
//  Copyright © 2019 Sávio Berdine. All rights reserved.
//

import Foundation
import Alamofire

class Model {
    
    class func requestBikePEStations(onSuccess: @escaping (_ response:[BikePEStations]) -> Void, onFailure: @escaping (_ error: String?) -> Void) {
        
        let headers: HTTPHeaders = ["content-type": "application/json"]
        //let parameters: Parameters = [:]
        
        Alamofire.request("http://dados.recife.pe.gov.br/api/action/datastore_search?resource_id=e6e4ac72-ff15-4c5a-b149-a1943386c031", method: .get, parameters: nil, headers: headers).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                onFailure("Failing finding BikePEStations")
                return
            }
            guard let value = response.result.value else {
                onFailure("Failing finding BikePEStations")
                return
            }
            
            guard let dicValue = value as? [String: Any] else {
                onFailure("Failing finding BikePEStations")
                return
            }
            
            guard let result = dicValue["result"] as? [String: Any] else {
                onFailure("Failing finding BikePEStations")
                return
            }
            
            guard let records = result["records"] as? [[String: Any]] else {
                onFailure("Failing finding BikePEStations")
                return
            }
            
            var stations: [BikePEStations] = []
            
            for element in records {
                guard let tit = element["nome"] as? String else {
                    onFailure("Failing finding BikePEStations")
                    return
                    
                }
                guard let loc = element["localizacao"] as? String else {
                    onFailure("Failing finding BikePEStations")
                    return
                    
                }
                guard let latS = element["latitude"] as? String else {
                    onFailure("Failing finding BikePEStations")
                    return
                    
                }
                guard let longS = element["longitude"] as? String else {
                    onFailure("Failing finding BikePEStations")
                    return
                    
                }
                guard let lat = Double(latS) else {
                    onFailure("Failing finding BikePEStations")
                    return
                    
                }
                guard let long = Double(longS) else {
                    onFailure("Failing finding BikePEStations")
                    return
                    
                }
                let station: BikePEStations = BikePEStations(title: tit, latitude: lat, longitude: long, location: loc)
                stations.append(station)
            }
            
            onSuccess(stations)
            
        }
        
    }
    
}
