//
//  Places.swift
//  maps_md3
//
//  Created by viva brolite on 12/06/2020.
//  Copyright © 2020 vivabrolite. All rights reserved.
//

import MapKit
import AddressBook
import Contacts

class FavLocation: NSObject, MKAnnotation{
    
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    
    init(title: String, locationName: String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    var subtitle: String? {
        return locationName
    }
    
    
    func mapItem() -> MKMapItem
    {
        let addressDictionary = [String(CNPostalAddressStreetKey) : subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary as [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(title as Optional) \(subtitle as Optional)"
        
        return mapItem
    }
    
}
