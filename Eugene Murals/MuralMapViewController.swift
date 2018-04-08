//
//  FirstViewController.swift
//  Eugene Murals
//
//  Created by Andrew on 3/11/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MuralMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    // Create a location manager to trigger user tracking
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()

    let region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 44.051074,longitude: -123.101989), span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))

    var murals: [Mural]?
    var selectedMural: Mural?

    //MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        registerAnnotationViewClasses()
        subscribeToNotificaitons()
        setupMapView()
        if MuralManager.sharedInstance.dataReadyForUse {
            populateMapView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Map Funcitons
    func registerAnnotationViewClasses() {
        mapView.register(MuralAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func setupMapView() {
        mapView.showsCompass = true
        mapView.delegate = self
        mapView.setRegion(region, animated: true)
        mapView.mapType = .mutedStandard
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let loginStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = loginStoryboard.instantiateViewController(withIdentifier: "muralDetails") as! MuralDetailViewController
        if let selectedMarker = view.annotation as? MuralAnnotation  {
            if let selectedMural = MuralManager.sharedInstance.muralFrom(uid: selectedMarker.uid) {
               viewController.mural = selectedMural
            }
        }
        show(viewController, sender: self)
    }

    func populateMapView() {
        mapView.addAnnotations(MuralAnnotation.mapAnnotations(fromMurals: MuralManager.sharedInstance.murals))
    }

    @objc func muralDataReady() {
        mapView.removeAnnotations(mapView.annotations)
        populateMapView()
    }
    
    @objc func refreshMap() {
        mapView.removeAnnotations(mapView.annotations)
        populateMapView()
    }

    func subscribeToNotificaitons() {
        NotificationCenter.default.addObserver(self, selector: #selector(MuralMapViewController.muralDataReady), name: .muralDataReady, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MuralMapViewController.refreshMap), name: .visitedStatusChange, object: nil)
    }

    
}


