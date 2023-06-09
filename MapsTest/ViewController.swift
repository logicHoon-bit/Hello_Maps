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
    var addAddressViewButton: UIButton!
    var directionViewButton: UIButton!
    var directions = [String]()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setLocationManager()
        
       
        
        configureSubviews() //layout
        addPointOfInterest()
    }

    //MARK: setLocationManager
    func setLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone //업데이트를 위한 이동해야하는 최소거리, kCLDistanceFilterNone을 설정함으로서 위치가 변경될 때 마다 업데이트됨
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Action Logic
    
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
        annotation.coordinate = CLLocationCoordinate2D(latitude:  36.3164, longitude: 127.4444)
        annotation.title = "My Annotatiom"
        annotation.subtitle = "subtitle"
        //annotation.imageURL = "pin@x3"
        mapView.addAnnotation(annotation)
    }
    
    @objc func showAddAddressView() {
        let alertVC = UIAlertController(title: "Add Address", message: "input message", preferredStyle: .alert)
        
        alertVC.addTextField() { textField in
            
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            if let textField = alertVC.textFields?.first, let search = textField.text { //address
                  
                self.findNearbyPOI(by: search)
                
                /*
                self.reverseGeocode(address: textField.text!) { placemark in
                    
                    let destinationPlacemark = MKPlacemark(coordinate: (placemark.location?.coordinate)!)
                    
                    //사용자의 현재 위치의 mapItem 생성
                    let startingMapItem = MKMapItem.forCurrentLocation()
                    //입력한 주소의 mapItem생성
                    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                    
                    let request = MKDirections.Request()
                    request.transportType = .walking
                    request.source = startingMapItem
                    request.destination = destinationMapItem
                    
                    let direction = MKDirections(request: request)
                    direction.calculate { response, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        //rotue.first에는 경로의 경우의 수 중 가장 빠른 경로를 가지고 있음
                        guard let response = response, let route = response.routes.first else {
                            return
                        }
                        
                        //경로에서 이동할 step이 있는 경우 실행
                        if !route.steps.isEmpty {
                            for step in route.steps {
                                print(step.instructions) //지점에 대한 방향 안내의 string
                                
                                self.directions.append(step.instructions)
                            }
                        }
                        
                        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                        
                    }
                    
                }
                */
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true)
    }
    
    @objc func showDirectionTableView() {
        let directionTableVC = DirectionTableViewController()
        directionTableVC.directions = self.directions
        present(directionTableVC, animated: true)
    }
    
    //MARK: - CustomLogic
    
    private func findNearbyPOI(by searchTerm: String) {
        
        //다시 검색하기 위해 맵위에 올라간 어노테이션들 제거
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.region = self.mapView.region
        
        let locationSearch = MKLocalSearch(request: request)
        locationSearch.start { respon, error in
            
            guard let respon = respon, error == nil else {
                return
            }
            
            for mapItem in respon.mapItems {
                self.addPlaceMarkToMap(placeMark: mapItem.placemark)
            }
            
        }
        
    }
    
    private func reverseGeocode(address: String, _ completion: @escaping (CLPlacemark) -> ()) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placeMarks, error in //placeMarks: 실제 찾은 위치
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placeMarks = placeMarks, let placeMark = placeMarks.first else {
                return
            }
            
            //self.addPlaceMarkToMap(placeMark: placeMark)
            completion(placeMark)
        }
        
    }
    
    private func addPlaceMarkToMap(placeMark: CLPlacemark) {
        
        let coordinate = placeMark.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.title = placeMark.name
        self.mapView.addAnnotation(annotation)
        
    }
    
    private func addPointOfInterest() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 36.3164, longitude: 127.4444)
        self.mapView.addAnnotation(annotation)
        
        //location 범위
        let region = CLCircularRegion(center: annotation.coordinate, radius: 200, identifier: "Home")
        region.notifyOnEntry = true //didEnterRegion Delegate호출
        region.notifyOnExit = true //didExitRegion Delegate호출
        
        self.mapView.addOverlay(MKCircle(center: annotation.coordinate, radius: 200)) //radius 는 반경의 miter 값
        
        //지정된 영역(region) 모니터링을 시작
        self.locationManager.startMonitoring(for: region)
    }
    
    private func configureView(_ annotationView: MKAnnotationView?) {
        
        let snapShotSize = CGSize(width: 200, height: 200)
        
        let snapShotView = UIView(frame: CGRect.zero)
        snapShotView.translatesAutoresizingMaskIntoConstraints = false
        snapShotView.widthAnchor.constraint(equalToConstant: snapShotSize.width).isActive = true
        snapShotView.heightAnchor.constraint(equalToConstant: snapShotSize.height).isActive = true
        
        let options = MKMapSnapshotter.Options()
        options.size = snapShotSize
        options.mapType = .satelliteFlyover
        options.camera = MKMapCamera(lookingAtCenter: (annotationView?.annotation?.coordinate)!, fromDistance: 10, pitch: 65, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            if let snapshot = snapshot {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: snapShotSize.width, height: snapShotSize.height))
                imageView.image = snapshot.image
                snapShotView.addSubview(imageView)
            }
        }
        
        annotationView?.detailCalloutAccessoryView = snapShotView
        
    }
    
    
}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    //영역에 들어갔을때 호출
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
    }
    
    //영역에 나갔을때 호출
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
    }
    
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    /*
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        mapView.setRegion(region, animated: true)
    }*/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { //사용자 위치엔 적용을 배재하기위한 로직
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
//            annotationView?.glyphText = "✈️"
//            annotationView?.glyphImage //imgae 삽입옵션
//            annotationView?.markerTintColor = .blue
//            annotationView?.glyphTintColor = .white //annotation안의 텍스트의 색상옵션
            
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        
//        if let isAnnotation = annotation as? Annotation {
//            annotationView?.image = UIImage(imageLiteralResourceName: isAnnotation.imageURL)
//        }
        
        //configureView(annotationView)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation as? Annotation else {
            return
        }
        
        let customCalloutView = CustomCalloutView(annotation: annotation, frame: CGRect.zero)
        
        customCalloutView.add(to: view)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        view.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
        
    }

    //지정한 오버레이를 그릴 때 사용할 렌더러 개체를 Delegate에게 요청
    //route의 polyline을 추가 할 때 이 함수가 호출됨
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple //아마 가장자리 색상인듯
            circleRenderer.fillColor = .purple
            circleRenderer.alpha = 0.4 //투명도
            return circleRenderer
        }
        else if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.lineWidth = 5.0
            polylineRenderer.strokeColor = .purple
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
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
        addAddressViewButton = UIButton()
        directionViewButton = UIButton()
    }
    
    func addSubviews() {
        view.addSubview(mapView)
        mapView.addSubview(mapSegment)
        mapView.addSubview(addAnnotation)
        mapView.addSubview(addAddressViewButton)
        mapView.addSubview(directionViewButton)
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
        
        addAddressViewButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addAddressViewButton.tintColor = .black
        addAddressViewButton.addTarget(self, action: #selector(showAddAddressView), for: .touchUpInside)
        
        directionViewButton.setImage(UIImage(systemName: "signpost.right.and.left"), for: .normal)
        directionViewButton.tintColor = .black
        directionViewButton.addTarget(self, action: #selector(showDirectionTableView), for: .touchUpInside)
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
        
        addAddressViewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addAddressViewButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addAddressViewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        directionViewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            directionViewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            directionViewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

