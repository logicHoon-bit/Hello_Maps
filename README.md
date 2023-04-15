# Hello_Maps

MKMapView

- mapView 초기설정

```swift
mapView = MKMapView(frame: view.frame)
        mapView.delegate = self
        mapView.showsUserLocation = true //사용자 현재위치
        mapView.userTrackingMode = .followWithHeading //사용자가 바라보는 방향 감지
        view.addSubview(mapView)
```

- 어노테이션 추가 로직

```swift
@objc func addAnnotationButtonPressed() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude:  37, longitude: -122)
        annotation.title = "My Annotatiom"
        mapView.addAnnotation(annotation)
    }
```

- 기억안남(아마 척도제스쳐 추가인듯)
    
    ****MKZoomControl 로 축소/확대버튼을 구현할 수 있음****
    

```swift
pinchGesture.addTarget(self, action: #selector(didPinch))
mapView.addGestureRecognizer(pinchGesture)

//사용자가 지도 척도를 컨트롤했을때 호출됨
@objc func didPinch(_ sender: UIPinchGestureRecognizer) {
        //지도가 변경되려고 시도된 상태
        if sender.state == .changed {
            let scale = sender.scale
            let newScale = currentScale * Double(scale)
            mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: CLLocationDistanceMax), animated: false)
            mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: newScale), animated: false)
        }else if sender.state == .ended {
            currentScale = mapView.cameraZoomRange.maxCenterCoordinateDistance
        }
    }
```

- mapType

```swift
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
```

MKMapViewDelegate

- 사용자의 위치가 업데이트 될 때 이 메서드가 호출

```swift
func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
```

- mapView(didUpdate)지도축척 컨트롤 권장하는 방법
    
    s****etRegion(_:animated:)****
    
    ```swift
    func setRegion(
        _ region: MKCoordinateRegion,
        animated: Bool
    )
    ```
    
    region: 설정하려는 영역을 나타내려는 ‘`MKCoordinateRegion`’ 객체
    
    animated: 영역이 변경할 떄 애니메이션 효과를 적용할지의 여부
    

```swift
func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        mapView.setRegion(region, animated: true)
    }
```

- 어노테이션자체에 대한 사용자 지정 뷰를 만들 수 있음
    
    기본 어노테이션뷰내부 속성 커스텀만 한경우
    
    ```swift
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { //사용자 위치엔 적용을 배재하기위한 로직
                return nil
            }
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation") as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
                annotationView?.glyphText = "✈️"
                annotationView?.glyphImage //imgae 삽입옵션
                annotationView?.markerTintColor = .blue
                annotationView?.glyphTintColor = .white //annotation안의 텍스트의 색상옵션
                
                annotationView?.canShowCallout = true
            }else{
                annotationView?.annotation = annotation
            }
            
    //        if let isAnnotation = annotation as? Annotation {
    //            annotationView?.image = UIImage(imageLiteralResourceName: isAnnotation.imageURL)
    //        }
            
            return annotationView
        }
    ```
    

```swift
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
       
        configureView(annotationView)

        return annotationView
    }
```

어노테이션의 디자인이나 어노테이션 터치 이벤트(콜아웃 뷰) 처리

canShowCallout: **`MKAnnotationView`**가 선택되었을 때 해당 어노테이션 뷰의 오른쪽에 나타나는 풍선 모양의 캡션(Callout)을 표시할지 여부를 나타냄

- CalloutView Cutom

```swift
private func configureView(_ annotationView: MKAnnotationView?) {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.backgroundColor = .green
        
        annotationView?.leftCalloutAccessoryView = UIImageView(image: UIImage(systemName: "pin.fill"))
        annotationView?.rightCalloutAccessoryView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        annotationView?.detailCalloutAccessoryView = view
        
    }
```

# 주소 검색

---

- showAddAddressView

```swift
@objc func showAddAddressView() {
        let alertVC = UIAlertController(title: "Add Address", message: "input message", preferredStyle: .alert)
        
        alertVC.addTextField() { textField in
            
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            if let textField = alertVC.textFields?.first {
                self.reverseGeocode(address: textField.text!)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true)
    }
```

주소 검색창을 띄우기 위해 alert창을 띄우는 ‘+’버튼

- GeoCoder

```swift
private func reverseGeocode(address: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placeMarks, error in //placeMarks: 실제 찾은 위치
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placeMarks = placeMarks, let placeMark = placeMarks.first else {
                return
            }
            
            self.addPlaceMarkToMap(placeMark: placeMark)
        }
    }
```

- addPlaceMark

```swift
private func addPlaceMarkToMap(placeMark: CLPlacemark) {
        
        let coordinate = placeMark.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        self.mapView.addAnnotation(annotation)
        
    }
```

# GeoFencing

---

- addPointOfInterest

```swift
private func addPointOfInterest() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 36.3164, longitude: 127.4444)
        self.mapView.addAnnotation(annotation)
        
        //location 범위
        let region = CLCircularRegion(center: annotation.coordinate, radius: 200, identifier: "Home")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        self.mapView.addOverlay(MKCircle(center: annotation.coordinate, radius: 200)) //radius 는 반경의 miter 값
        
        //지정된 영역(region) 모니터링을 시작
        self.locationManager.startMonitoring(for: region)
    }
```

annotation 생성 및 추가

범위(region) 생성 및 모니터링 시작

# CLLocationManagerDelegate

```swift
//영역에 들어갔을때 호출
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
    }
    
    //영역에 나갔을때 호출
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
    }
```

범위에 들어가고 나올 때의 시점에 정의할 로직 여기다가 작성

# MKMapViewDelegate

- func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer

```swift
//지정한 오버레이를 그릴 때 사용할 렌더러 개체를 Delegate에게 요청
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            var circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple //아마 가장자리 색상인듯
            circleRenderer.fillColor = .purple
            circleRenderer.alpha = 0.4 //투명도
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
```

 -맵 뷰에 오버레이 객체가 추가되면, 맵 뷰는 해당 오버레이 객체에 대한 렌더러 객체를 생성하고, 이 메서드를 호출하여 해당 오버레이 객체에 대한 렌더러 객체를 가져옵니다. (오버레이의 속성을 이 메서드에 작성)

# Destination

---

- showAddAddressView

```swift
@objc func showAddAddressView() {
        let alertVC = UIAlertController(title: "Add Address", message: "input message", preferredStyle: .alert)
        
        alertVC.addTextField() { textField in
            
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            if let textField = alertVC.textFields?.first { //address
                                
                self.reverseGeocode(address: textField.text!) { placemark in
                    
                    let destinationPlacemark = MKPlacemark(coordinate: (placemark.location?.coordinate)!)
                    
                    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                    
                    //지도항목을 표시하는 기능(지도앱으로)
                    MKMapItem.openMaps(with: [destinationMapItem])
                }
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true)
    }
```

alert 호출하는 코드

ok 선택시 reverseGeocode함수에 주소string을 넘겨주고 completion커스텀

-전달 받은 placemark(CLPlacemark)를 MKPlacemark로

-MKPlacemark를 MKMapItem으로

-MKMapItem으로 앱의 지도앱 호출

- reverseGeocode

```swift
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
```

-넘겨 받은 주소string을 geocoder에 넣어 completion으로 CLPlacemark 사용

-placemark단일 개체 추출 후 completion 바디로 호출

-이때 geocodeAddressString는 비동기적으로 실행하기 때문에 반드시 escaping을 사용해 외부에서 실행 할수 있게 만들어야됨

## 직접 경로 탐색 구현

```swift
let okAction = UIAlertAction(title: "OK", style: .default) { action in
            if let textField = alertVC.textFields?.first { //address
                                
                self.reverseGeocode(address: textField.text!) { placemark in
                    
                    let destinationPlacemark = MKPlacemark(coordinate: (placemark.location?.coordinate)!)
                    
                    //사용자의 현재 위치의 mapItem 생성
                    let startingMapItem = MKMapItem.forCurrentLocation()
                    //입력한 주소의 mapItem생성
                    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                    
                    let request = MKDirections.Request()
                    request.transportType = .automobile
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
												//경로 오버레이 추가
												self.mapView.addOverlay(route.polyline, level: .aboveRoads)

                    }
                    
                }
                
            }
        }
```

-route 배열에 첫번째 요소는 가장 가까운 경로

-route에서 steps은 경로의 단계 루트

-request에 시자mapItem과 도착지mapItem을 넘겨야 됨 (도보, 자전거, 자동차 옵션 선택 가능)

-steps는 경로 안내의 string의 값임

-directions은 로컬배열

- 경로 오버레이(route.polyline)를 추가할경우 Delegate에 의해 **func** mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer 함수가 오출됨
    

```swift
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
```

Renderer 생성 및 반환

## Search Annotation

```swift
//alert에서 확인 버튼을 클릭했을때 실행
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
```
