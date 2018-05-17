//
//  StudentsMapViewController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 08/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class StudentsMapViewController: UIViewController, MKMapViewDelegate {

    var pins = [MKPointAnnotation]()
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        populateStudentsPins()
        NotificationCenter.default.addObserver(self, selector: #selector(StudentsMapViewController.reloadInputViews), name: Notification.Name(rawValue: refreshNotificationKey), object: nil)
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.calloutOffset = CGPoint(x: -5, y: 5)
            pinView!.tintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func populateStudentsPins() {
        startAnimating()
        ParseClient.sharedInstance().getStudentsInfo() { (success, error) in
            if success{
                DispatchQueue.main.async {
                    self.createAnotations()
                    self.stopAnimating()
                    self.mapView.addAnnotations(self.pins)
                }
            } else {
                self.showAlert(error?.localizedDescription ?? "An Unknown error ocurred")
            }
        }
    }
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    if UIApplication.shared.canOpenURL(url) {
                        let sfVC = SFSafariViewController(url:url)
                        present(sfVC,animated: true, completion: nil)
                } else {
                    showAlert("Invalid URL!")
                    }
                }
            }
        }
    }
    
    
    func createAnotations() {
        
        let locations = DataSource.sharedInstance.studentsInformation
        for dictionary in locations {
            // create CLLocationDegree values from parsed values.
            var lat: CLLocationDegrees?
            var lon: CLLocationDegrees?
            var coordinate: CLLocationCoordinate2D?
            
            if let latitude = dictionary.latitude, let longitude = dictionary.longitude {
                lat = CLLocationDegrees(latitude)
                lon = CLLocationDegrees(longitude)
                //  create a CLLocationCoordinates2D instance
                coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            }
            
            let pin = MKPointAnnotation()
            if let coordinate = coordinate {
                pin.coordinate = coordinate
            }
            
            if let firstName = dictionary.firstName, let lastName = dictionary.lastName {
                pin.title = "\(firstName) \(lastName)"
            }
            if let mediaUrl = dictionary.mediaUrl {
                pin.subtitle = mediaUrl
            }
            self.pins.append(pin)
        
        }
    }
    
     override func reloadInputViews() {
        mapView.removeAnnotations(pins)
        pins.removeAll()
        DataSource.sharedInstance.studentsInformation.removeAll()
        populateStudentsPins()
    }
    
    
    
    func stopAnimating() {
        wheel.stopAnimating()
        self.view.alpha = 1.0
    }
    
    func startAnimating() {
        self.view.alpha = 0.4
        wheel.startAnimating()
    }
    
    func showAlert( _ message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


}
