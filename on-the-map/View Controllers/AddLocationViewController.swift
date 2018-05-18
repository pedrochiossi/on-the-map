//
//  AddLocationViewController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 08/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit
import CoreLocation
class AddLocationViewController: UIViewController, UITextFieldDelegate{

    // MARK: Properties
    

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // MARK : Geolocation
    
    @IBAction func findLocation(_ sender: Any) {
        
        guard  !locationTextField.text!.isEmpty || !urlTextField.text!.isEmpty else {
            showAlert("Empty URL or location! Please Try Again")
            return
        }
        guard urlTextField.text!.hasPrefix("https://") else {
            showAlert("URL does not contain https://")
            return
        }
        let url = urlTextField.text!
        let mapString = locationTextField.text!
        wheel.startAnimating()
        CLGeocoder().geocodeAddressString(mapString) { (placemarks, error) in
            
            guard (error == nil) else {
                if error.debugDescription.contains("Code=2"){
                    self.showAlert("Network Failure!")
                } else if error.debugDescription.contains("Code=8"){
                    self.showAlert("Could not find any location matching the string: "\(mapString)".")
                } else {
                    self.showAlert(error.debugDescription)
                }
                return
            }
            if let location = placemarks?.first?.location {
                DispatchQueue.main.async {
                    self.wheel.stopAnimating()
                    let locMapVC = self.storyboard?.instantiateViewController(withIdentifier: "addLocationMapVC") as! AddLocationMapViewController
                    locMapVC.locationString = mapString
                    locMapVC.urlForMap = url
                    locMapVC.coordinateForMap = location.coordinate 
                    self.navigationController?.pushViewController(locMapVC, animated: true)
                }
            }
        }
    }
    

    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: View Configuration
    
    func configureUI() {
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
        locationTextField.delegate = self
        urlTextField.delegate = self
        findLocationButton.layer.cornerRadius = 4.0
        locationTextField.layer.cornerRadius = 4.0
        urlTextField.layer.cornerRadius = 4.0
    }
    
    
    func showAlert( _ message: String?) {
        wheel.stopAnimating()
        let alert = UIAlertController(title: "Location Not Found", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //  MARK: Keyboard Notification Methods
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            view.frame.origin.y -= 0.5 * getKeyboardHeight(notification)
        }
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    
}
