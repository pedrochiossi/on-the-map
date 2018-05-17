//
//  AddLocationMapViewController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 08/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit
import MapKit
class AddLocationMapViewController: UIViewController, MKMapViewDelegate {
    
    
    var locationString: String!
    var urlForMap: String!
    var coordinateForMap: CLLocationCoordinate2D!
    
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        finishButton.isEnabled = false
        showUserAnnotation()
    }
    

    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func showUserAnnotation()  {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateForMap
        annotation.title = UdacityClient.sharedInstance().firstName! + " " + UdacityClient.sharedInstance().lastName!
        annotation.subtitle = urlForMap
        mapView.addAnnotation(annotation)
        let regionToZoom = MKCoordinateRegionMakeWithDistance(coordinateForMap, 2000, 2000)
        mapView.setRegion(regionToZoom, animated: true)
    }

    
    @IBAction func postStudentLocation(_ sender: Any) {
        wheel.startAnimating()
        ParseClient.sharedInstance().userLongitude = coordinateForMap.longitude
        ParseClient.sharedInstance().userLatitude = coordinateForMap.latitude
        ParseClient.sharedInstance().userMediaUrl = urlForMap
        ParseClient.sharedInstance().userMapString = locationString
        
        if ParseClient.sharedInstance().userObjectID != nil {
            updateStudentLocation()
        } else {
            createStudentLocation()
        }
        
    }
    
    
    func createStudentLocation() {
        
        ParseClient.sharedInstance().postStudentInfo() { (success, error) in
            
            if success{
                DispatchQueue.main.async {
                    self.wheel.stopAnimating()
                    self.performSegue(withIdentifier: "goBackToTBC", sender: self)
                }
            } else {
                self.showAlert(error?.localizedDescription ?? "Uknonwn error")
            }
        }
    }
    
    
    func updateStudentLocation() {
        
        ParseClient.sharedInstance().updateUserInfo() { (success, error) in
            if success{
                DispatchQueue.main.async {
                    self.wheel.stopAnimating()
                    self.performSegue(withIdentifier: "goBackToTBC", sender: self)
                }
            } else {
                self.showAlert(error?.localizedDescription ?? "Uknonwn error")
            }
        }
        
    }
                
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.calloutOffset = CGPoint(x: -5, y: 5)
            pinView!.tintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func showAlert( _ message: String?) {
        let alert = UIAlertController(title: "Failed to Add Location!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func configureUI() {
        let backButton = UIBarButtonItem(title: "Add Location", style: .plain, target: self, action: #selector(goBack))
        navigationItem.backBarButtonItem = backButton
        navigationItem.title = "Add Location"
        finishButton.layer.cornerRadius = 5.0
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        finishButton.isEnabled = true
    }
    
}
