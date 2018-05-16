//
//  TabBarController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 08/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit

let refreshNotificationKey = "RefreshButtonRequestNotification"

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func logout(_ sender: Any) {
        
        
        UdacityClient.sharedInstance().logoutFromSession() { (success, error ) in
            
            if success{
                DispatchQueue.main.async(execute:{ self.dismiss(animated: true, completion: nil)})
            } else {
                DispatchQueue.main.async(execute:{self.logOutAlert(error?.localizedDescription ?? "An Unknown Error Ocurred")})
            }
        }
    }
    
    @IBAction func reloadLocations(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name( rawValue: refreshNotificationKey), object: self)
    }
       
    
    
    @IBAction func addStudentLocation(_ sender: Any) {
        
        // checks if user has already posted a location
        ParseClient.sharedInstance().getUserInfo() { (success, error) in
            if success{
                    DispatchQueue.main.async {
                        let userName = UdacityClient.sharedInstance().firstName! + " " + UdacityClient.sharedInstance().lastName!
                        self.overwriteAlert("User \(userName) has already posted a Student Location. Would you like to overwrite their Location?")
                    }
                } else {
                
                print(error?.localizedDescription ?? "Unknown error") // i guees it's not working :(
                DispatchQueue.main.async {
                    let addLocationVC = self.storyboard?.instantiateViewController(withIdentifier: "addLocationVC") as! AddLocationViewController
                    self.navigationController?.pushViewController(addLocationVC, animated: true)
                }
            }
        }
    }
    
    func overwriteAlert(_ message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: { action in
            let addLocationVC = self.storyboard?.instantiateViewController(withIdentifier: "addLocationVC") as! AddLocationViewController
            self.navigationController?.pushViewController(addLocationVC, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func logOutAlert( _ message: String?) {
        let alert = UIAlertController(title: "Logout Failed!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
