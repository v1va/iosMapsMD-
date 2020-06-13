//
//  AddController.swift
//  maps_md3
//
//  Created by viva brolite on 11/06/2020.
//  Copyright © 2020 vivabrolite. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddViewCotroller: UIViewController{
    
    @IBOutlet var saveCoordsButton: UIView!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    
    var ref: DatabaseReference!
    
    
    func saveLocation(latitude: String, longitude: String){
        ref = Database.database().reference().child("Locations")
        ref.childByAutoId().setValue(["latitude":latitude, "longitude":longitude])
    }
    
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
        
        let latitude = String(latTextField.text!)
        let longitude = String(longTextField.text!)
        
        saveLocation(latitude: latitude, longitude: longitude)
    }
    
}
