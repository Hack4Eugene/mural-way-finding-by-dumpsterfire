//
//  MuralDetailViewController.swift
//  Eugene Murals
//
//  Created by Andrew & Charlie on 4/7/18.
//  Copyright © 2018 Andrew Nordahl & Charlie Chang. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SceneKit
import ARKit

class MuralDetailViewController: UIViewController, MKMapViewDelegate, ARSessionDelegate {
    //MARK: - Variables
    var mural: Mural = Mural()
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()

    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var visitedButton: UIButton!
    @IBOutlet weak var visitedLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var getRouteButton: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapRouteView: MKMapView!
    @IBOutlet weak var arScene: SceneLocationView!
    
    //MARK: - IBActions
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if mural.favorited {
            mural.favorited = false
            favoriteButton.setTitle("☆", for: .normal)
        } else {
            mural.favorited = true
            favoriteButton.setTitle("★", for: .normal)
        }
        NotificationCenter.default.post(name: .visitedStatusChange, object: nil)
        MuralManager.sharedInstance.saveUserData()
    }
    
    @IBAction func visitedButtonPressed(_ sender: Any) {
        if checkDistance() {
            visitedButton.setTitle(" ", for: .normal)
            visitedLoadingIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.visitedLoadingIndicator.stopAnimating()
                self.mural.visited = true
                self.visitedButton.setTitle("Visited", for: .normal)
                self.visitedButton.backgroundColor = UIColor.cyan
                self.visitedButton.isUserInteractionEnabled = false
                NotificationCenter.default.post(name: .visitedStatusChange, object: nil)
                MuralManager.sharedInstance.saveUserData()
            })
        } else {
            visitedButton.setTitle(" ", for: .normal)
            visitedLoadingIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.visitedLoadingIndicator.stopAnimating()
                self.visitedButton.setTitle("Get Closer", for: .normal)
                self.visitedButton.backgroundColor = UIColor.orange
                self.visitedButton.isUserInteractionEnabled = false
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                self.visitedButton.setTitle("Check-in", for: .normal)
                self.visitedButton.isUserInteractionEnabled = true
            })
        }
    }
    
    @IBAction func routeButtonPressed(_ sender: Any) {
        arScene.pause()
        if getRouteButton.titleLabel?.text == "Show Route" {
            mapRouteView.isHidden = false
            imageView.isHidden = true
            if ARConfiguration.isSupported {
                getRouteButton.setTitle("Show AR View", for: .normal)
            } else {
                getRouteButton.setTitle("Show Image", for: .normal)
            }
        }
        
        if getRouteButton.titleLabel?.text == "Show Image" {
            mapRouteView.isHidden = true
            arScene.isHidden = true
            imageView.isHidden = false
            getRouteButton.setTitle("Show Route", for: .normal)
        }
        
        if getRouteButton.titleLabel?.text == "Show AR View" {
            mapRouteView.isHidden = true
            imageView.isHidden = true
            arScene.isHidden = false
            arScene.run()
            getRouteButton.setTitle("Show Image", for: .normal)
        }
    }
    
    //MARK: - Lifecycle Funcitons
    override func viewDidLoad() {
        super.viewDidLoad()
        mapRouteView.delegate = self
        roundCorners()
        populateView()
        drawRoute()
        if ARConfiguration.isSupported {
            setupARView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
        styleNavigationBar()
        updateViewConstraints()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        arScene.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Setup Functions
    func setupARView() {
        arScene.locationDelegate = self
        let muralLocation = CLLocation(latitude: mural.latitude, longitude: mural.longitude)
        let pinImage = mural.image
        let pinLocationNode = LocationAnnotationNode(location: muralLocation, image: pinImage)
        arScene.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
    }
    
    func populateView() {
        //set labels
        nameLabel.text = mural.name
        artistLabel.text = "by " + mural.artist
        addressLabel.text = mural.address
        sponsorsLabel.text = mural.sponsors
        noteLabel.text = mural.note
        imageView.image = mural.image
        
        //set buttons
        if mural.favorited {
            favoriteButton.setTitle("★", for: .normal)
        }
        
        if mural.visited {
            visitedButton.setTitle("Visited", for: .normal)
            visitedButton.backgroundColor = UIColor.cyan
            visitedButton.isUserInteractionEnabled = false
        } else {
            visitedButton.setTitle("Check-in", for: .normal)
            visitedButton.backgroundColor = UIColor.orange
        }
    }
    
    func roundCorners() {
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        infoContainerView.layer.cornerRadius = 5.0
        buttonContainerView.layer.cornerRadius = 5.0
        getRouteButton.layer.cornerRadius = 5.0
        getRouteButton.clipsToBounds = true
        visitedButton.layer.cornerRadius = 5.0
        visitedButton.clipsToBounds = true
        mapRouteView.layer.cornerRadius = 5.0
        mapRouteView.clipsToBounds = true
    }
    
    func styleNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func checkDistance() -> Bool {
        let muralLocation: CLLocation = CLLocation.init(latitude: mural.latitude, longitude: mural.longitude)
        let currentDistance = muralLocation.distance(from: locationManager.location!)
        return currentDistance <= 50.0
    }
    
    //MARK: - Draw Route
    func drawRoute() {
        mapRouteView.addAnnotation(MuralAnnotation.mapAnnotations(fromMurals: [mural])[0])
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: mural.latitude, longitude: mural.longitude), addressDictionary: nil))
        //request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapRouteView.add(route.polyline)
                self.mapRouteView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        mapRouteView.showAnnotations([mapRouteView.annotations[0]], animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.purple
        return renderer
    }

    // MARK: - ARSessionObserver
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        resetTracking()
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arScene.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

//MARK: - Notification Name Extension
extension Notification.Name {
    static let visitedStatusChange = Notification.Name("visitedStatusChange")
}

//MARK: - SceneLocationViewDelegate Extension
extension MuralDetailViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
}
