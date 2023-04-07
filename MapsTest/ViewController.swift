//
//  ViewController.swift
//  MapsTest
//
//  Created by 이치훈 on 2023/04/07.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - Prooerties
    
    var locationManager = CLLocationManager()
    var mapView: MKMapView!
    var mapSegment: UISegmentedControl!
    var addAnnotation: UIButton!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setLocationManager()
        
        configureSubviews()
    }

    //MARK: setLocationManager
    func setLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone //업데이트를 위한 이동해야하는 최소거리, kCLDistanceFilterNone을 설정함으로서 위치가 변경될 때 마다 업데이트됨
         
        locationManager.startUpdatingLocation()
    }
    
  //test  1
    
    @objc func changedMapStyl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            self.mapView.mapType = .standard
        }
    }
    
    @objc func addAnnotationButtonPressed() {
        let annotation = Annotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude:  37, longitude: -122)
        annotation.title = "My Annotatiom"
        annotation.subtitle = "subtitle"
        annotation.imageURL = "pin@x3"
        mapView.addAnnotation(annotation)
    }
    
}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { //사용자 위치엔 적용을 배재하기위한 로직
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
            annotationView?.canShowCallout = true
        }else{
            annotationView?.annotation = annotation
        }
        
        if let isAnnotation = annotation as? Annotation {
            annotationView?.image = UIImage(imageLiteralResourceName: isAnnotation.imageURL)
        }
        
        return annotationView
    }
}

//MARK: - ConfigureSubviewsCase

extension ViewController: ConfigureSubviewsCase {
    func configureSubviews() {
        createSubviews()
        addSubviews()
        setupLayouts()
    }
    
    func createSubviews() {
        mapView = MKMapView(frame: view.frame)
        mapSegment = UISegmentedControl(items: ["Maps", "Satellite", "Hybrid"])
        addAnnotation = UIButton()
    }
    
    func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(mapSegment)
        view.addSubview(addAnnotation)
    }
    
    func setupLayouts() {
        setupSubviewsLayouts()
        setupSubviewsConstraints()
    }
    
    
}

extension ViewController: SetupSubviewsLayouts {
    func setupSubviewsLayouts() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapSegment.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        mapSegment.selectedSegmentIndex = 0
        mapSegment.addTarget(self, action: #selector(changedMapStyl), for: .valueChanged)
        
        addAnnotation.setTitle("Add Annotation", for: .normal)
        addAnnotation.backgroundColor = .systemBlue
        addAnnotation.tintColor = .white
        addAnnotation.layer.cornerRadius = 10
        addAnnotation.addTarget(self, action: #selector(addAnnotationButtonPressed), for: .touchUpInside)
    }
    
    
}

extension ViewController: SetupSubviewsConstraints {
    func setupSubviewsConstraints() {
        mapSegment.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapSegment.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            mapSegment.widthAnchor.constraint(equalToConstant: 200),
            mapSegment.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addAnnotation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addAnnotation.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addAnnotation.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

