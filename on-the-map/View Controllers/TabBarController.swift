//
//  OnTheMapTabBarController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 08/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    

    @IBAction func logout(_ sender: Any) {
        UdacityClient.sharedInstance().logoutFromSession() { (success, error ) in
            
            if success{
                DispatchQueue.main.async(execute:{ self.dismiss(animated: true, completion: nil)})
            } else {
                DispatchQueue.main.async(execute: {self.showAlert(error?.localizedDescription ?? "An Unknown Error Ocurred")})
            }
        }
    }
    
    @IBAction func reloadMap(_ sender: Any) {
        
    }
    
    
    @IBAction func addStudentLocation(_ sender: Any) {
        let addLocationVC = storyboard?.instantiateViewController(withIdentifier: "addLocationVC") as! AddLocationViewController
        present(addLocationVC, animated: true)
    }
    
    
    
    func showAlert( _ message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
