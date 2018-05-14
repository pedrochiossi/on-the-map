//
//  StudentsTableViewController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 14/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit
import SafariServices
class StudentsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var wheel: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(StudentsTableViewController.reload), name: Notification.Name(rawValue: refreshNotificationKey), object: nil)
        tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentsInformation.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentsCell", for: indexPath) as UITableViewCell
        let student = ParseClient.sharedInstance().studentsInformation[indexPath.row]
        cell.textLabel?.text = student.firstName! + " " + student.lastName!
        cell.detailTextLabel?.text = student.mediaUrl!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let urlToOpen = ParseClient.sharedInstance().studentsInformation[indexPath.row].mediaUrl {
            if let url = URL(string: urlToOpen) {
                if UIApplication.shared.canOpenURL(url) {
                    let sfVC = SFSafariViewController(url:url)
                    present(sfVC,animated: true, completion: nil)
                } else {
                    showAlert("Invalid URL!")
                }
            }
        }
    }
    
    
    @objc func reload() {
        wheel.startAnimating()
        ParseClient.sharedInstance().studentsInformation.removeAll()
        ParseClient.sharedInstance().getStudentsInfo() { (success, error) in
            if success{
                DispatchQueue.main.async {
                    self.wheel.stopAnimating()
                    self.tableView.reloadData()
                }
            } else {
                self.showAlert(error?.localizedDescription ?? "Unknown error ocurred")
            }
        }
    }
    
    
    func showAlert( _ message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
