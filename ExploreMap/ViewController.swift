//
//  ViewController.swift
//  ExploreMap
//
//  Created by Henry Aguinaga on 2018-11-16.
//  Copyright © 2018 Henry Aguinaga. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var lblNotificationOutlet: UILabel!
    
    @IBOutlet weak var mapOutlet: MKMapView!
    let myGeocoder :CLGeocoder = CLGeocoder()
    var initialLabelOrigin : CGPoint?
    var pinColorForAnnotationPair : UIColor?
    
    
    func getRandomColor() -> UIColor {
        
        let randomRed = CGFloat(arc4random_uniform(256)) / 255
        let randomGreen = CGFloat(arc4random_uniform(256)) / 255
        let randomBlue = CGFloat(arc4random_uniform(256)) / 255
        
        let randomColor = UIColor.init(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
   
        return randomColor
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let newAnnotationView = MKPinAnnotationView()
        newAnnotationView.animatesDrop = true
        newAnnotationView.pinTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        newAnnotationView.canShowCallout = true
        
        if annotation.title! == "Vancouver" {
            
            newAnnotationView.pinTintColor = getRandomColor()
            let vancouverImage = UIImageView.init(image: #imageLiteral(resourceName: "vancouver"))
            vancouverImage.frame = CGRect(origin: newAnnotationView.frame.origin, size: CGSize(width: 30, height: 30))
            
            newAnnotationView.leftCalloutAccessoryView = vancouverImage
            
        } else if annotation.title! == "Point A" || annotation.title! == "Point B" {
            newAnnotationView.pinTintColor = pinColorForAnnotationPair
        }
        
        else {
            
            newAnnotationView.pinTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
        
        return newAnnotationView
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerOfMap = mapOutlet.centerCoordinate
        let location = CLLocation(latitude: centerOfMap.latitude, longitude: centerOfMap.longitude)
        
        myGeocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.first
            let message = "Map is centered in : " + (place?.ocean ?? place?.locality ?? place?.inlandWater ?? "Some Place")
       
            self.showNotification(message: message)
        }
        
    }
    
    func showNotification(message : String) {
        lblNotificationOutlet.frame.origin.y = view.frame.height
        lblNotificationOutlet.alpha = 1
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            self.lblNotificationOutlet.frame.origin.y = (self.initialLabelOrigin?.y)!
            self.lblNotificationOutlet.text = message
            
        }, completion: {(isFinnished : Bool) in
            UIView.animate(withDuration: 1, animations: {
                self.lblNotificationOutlet.alpha = 0
            })
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialLabelOrigin = lblNotificationOutlet.frame.origin

        lblNotificationOutlet.alpha = 0
        let vancouver = CLLocation(latitude: 49.263570, longitude: -123.138570)
        
        let annotationInVancouver = MKPointAnnotation()
        annotationInVancouver.coordinate = vancouver.coordinate
        annotationInVancouver.title = "Vancouver"
        annotationInVancouver.subtitle = "Canada"
        mapOutlet.addAnnotation(annotationInVancouver)
        mapOutlet.centerCoordinate = annotationInVancouver.coordinate
        
        
    }

    @IBAction func tapOnMapAction(_ sender: UITapGestureRecognizer) {
        
        
        
        if sender.state == .ended {
            let touchLocationAsPoint: CGPoint = sender.location(in: view)
            let touchLocationAsCoordinate : CLLocationCoordinate2D = mapOutlet.convert(touchLocationAsPoint, toCoordinateFrom: view)
            
            let newLocation = CLLocation(latitude: touchLocationAsCoordinate.latitude, longitude: touchLocationAsCoordinate.longitude)
            
            myGeocoder.reverseGeocodeLocation(newLocation) { (placemark, error) in
                
                let locality = placemark?[0].locality ?? "Somewhere"
                let country = placemark?[0].country ?? "Some Country"
                
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate = touchLocationAsCoordinate
                
                newAnnotation.title = locality
                newAnnotation.subtitle = country
                
                self.mapOutlet.addAnnotation(newAnnotation)
                
                
            }

            UIView.animate(withDuration: 1.5, animations: {
                self.mapOutlet.centerCoordinate = touchLocationAsCoordinate
            })
        }
    }
    
    
    @IBAction func doubleTapTwoFingersOnMapAction(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            pinColorForAnnotationPair = getRandomColor()
            
            let pointA : CGPoint = sender.location(ofTouch: 0, in: view)
            let pointB : CGPoint = sender.location(ofTouch: 1, in: view)
            
            let coordinateOfPointA : CLLocationCoordinate2D = mapOutlet.convert(pointA, toCoordinateFrom: view)
        
            let coordinateOfPointB : CLLocationCoordinate2D = mapOutlet.convert(pointB, toCoordinateFrom: view)
       
            let annotationA = MKPointAnnotation()
            annotationA.coordinate = coordinateOfPointA
            annotationA.title = "Point A"
            
            let annotationB = MKPointAnnotation()
            annotationB.coordinate = coordinateOfPointB
            annotationB.title = "Point B"
            
            mapOutlet.addAnnotations([annotationA, annotationB])
            
            let locationA : CLLocation = CLLocation(latitude: coordinateOfPointA.latitude, longitude: coordinateOfPointA.longitude)
            
            let locationB : CLLocation = CLLocation(latitude: coordinateOfPointB.latitude, longitude: coordinateOfPointB.longitude)
        
            let distanceInMeters = locationA.distance(from: locationB)
       
            let distanceInKm = distanceInMeters / 1000
       
            let message = String.init(format: "Distance is %.2f km", distanceInKm)
       
            showNotification(message: message)
        }
    }
    
}

