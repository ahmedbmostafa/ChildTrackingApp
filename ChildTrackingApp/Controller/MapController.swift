//
//  MapController.swift
//  ChildTrackingApp
//
//  Created by ahmed mostafa on 9/3/20.
//  Copyright © 2020 ahmed mostafa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import Firebase

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var childLatt = Double()
    var childLonn = Double()
    var childLattSec = Double()
    var childLonnSec = Double()
    var parentLatt = Double()
    var parentLonn = Double()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lat = manager.location?.coordinate.latitude
        let lon = manager.location?.coordinate.longitude
        
        if currentUser?.email == "a@gmail.com" {
            db.collection("child").document("child").setData([
                "lat":lat!
                , "lon":lon!]
                , merge: true)
        } else {
            db.collection("child2").document("child2").setData([
                "lat":lat!
                , "lon":lon!]
                , merge: true)
        }
        
        queryChildLocation()
        queryChildLocationSecond()
        queryParentLocation()
        addAnnotaions()
    }
    
    
    func queryChildLocation() {
        
        let childquery = db.collection("child").whereField("provider", isEqualTo: "Firebase")
        childquery.getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }else {
                for doc in snapshot!.documents  {
                    let fetchData = doc.data()
                    guard let childLat = fetchData["lat"] as? Double else {return}
                    guard let childLon = fetchData["lon"] as? Double else {return}
                    self.childLatt = childLat
                    self.childLonn = childLon
                }
            }
        }
    }
    
    func queryChildLocationSecond() {
        
        let childquery = db.collection("child2").whereField("provider", isEqualTo: "Firebase")
        childquery.getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }else {
                for doc in snapshot!.documents  {
                    let fetchData = doc.data()
                    guard let childLat = fetchData["lat"] as? Double else {return}
                    guard let childLon = fetchData["lon"] as? Double else {return}
                    self.childLattSec = childLat
                    self.childLonnSec = childLon
                }
            }
        }
    }
    
    func queryParentLocation() {
        
        let parentquery = db.collection("Parent").whereField("provider", isEqualTo: "Firebase")
        parentquery.getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }else {
                for doc in snapshot!.documents  {
                    let fetchData = doc.data()
                    guard let parentLat = fetchData["lat"] as? Double else {return}
                    guard let parentLon = fetchData["lon"] as? Double else {return}
                    self.parentLatt = parentLat
                    self.parentLonn = parentLon
                }
            }
        }
    }
    

    func addAnnotaions () {
        
        let parentAnno = MKPointAnnotation()
        parentAnno.coordinate.latitude = parentLatt
        parentAnno.coordinate.longitude = parentLonn
        parentAnno.title = "MY Parent LOCATON"
        
        let childAnno = MKPointAnnotation()
        childAnno.coordinate.latitude = childLatt
        childAnno.coordinate.longitude = childLonn
        childAnno.title = "MY LOCATION"
        
        let childSecAnno = MKPointAnnotation()
        childSecAnno.coordinate.latitude = childLattSec
        childSecAnno.coordinate.longitude = childLonnSec
        childSecAnno.title = "MY LOCATION Sec"
        
        let parentChildAnno = [parentAnno, childAnno, childSecAnno] as [MKAnnotation]
        mapView.addAnnotations(parentChildAnno)
        for annotaion in mapView.annotations {
            if annotaion.isKind(of: MKPointAnnotation.self){
                mapView.removeAnnotation(annotaion)
            }
        }
        mapView.addAnnotations(parentChildAnno)
        mapView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
}
