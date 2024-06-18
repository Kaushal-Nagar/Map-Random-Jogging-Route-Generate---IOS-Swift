//
//  Extension.swift
//  Map Loop Route Task
//
//  Created by webcodegenie on 14/06/24.
//

import Foundation
import UIKit
//import CoreLocation
//
//extension AppDelegate: CLLocationManagerDelegate {
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .denied: // Setting option: Never
//            print("LocationManager didChangeAuthorization denied")
//        case .notDetermined: // Setting option: Ask Next Time
//            print("LocationManager didChangeAuthorization notDetermined")
//        case .authorizedWhenInUse: // Setting option: While Using the App
//            print("LocationManager didChangeAuthorization authorizedWhenInUse")
//        case .authorizedAlways: // Setting option: Always
//            print("LocationManager didChangeAuthorization authorizedAlways")
//        case .restricted: // Restricted by parental control
//            print("LocationManager didChangeAuthorization restricted")
//        default:
//            print("LocationManager didChangeAuthorization")
//        }
//    }
//}

extension UIViewController{
    func ShowAlertBox(Title: String , Message : String){
        let Alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
        
        Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//            print("Handle Ok logic here")
            Alert.dismiss(animated: true)
        }))
        self.present(Alert, animated: true, completion: nil)
    }
}
