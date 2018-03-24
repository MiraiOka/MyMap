import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var mapView: MapView!
    
    let myLocationManager = CLLocationManager()
    
    
    override func loadView() {
        let nib = UINib(nibName: MapView.nibName, bundle: nil)
        mapView = nib.instantiate(withOwner: nil, options: nil).first as! MapView
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.textField.delegate = self
        mapView.displayMapView.delegate = self
        myLocationManager.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed))
        mapView.displayMapView.addGestureRecognizer(longPressGesture)
        
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            myLocationManager.requestWhenInUseAuthorization()
        }
        
        myLocationManager.startUpdatingLocation()
        mapView.displayMapView.showsUserLocation = true
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began {
            return
        }
        
        let tappedLocation = sender.location(in: mapView.displayMapView)
        let tappedPoint = mapView.displayMapView.convert(tappedLocation, toCoordinateFrom: mapView.displayMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedPoint
        annotation.title = "タイトル"
        annotation.subtitle = "サブタイトル"
        mapView.displayMapView.addAnnotation(annotation)
        
    }
}

extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let searchKeyword = textField.text else { return false }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchKeyword, completionHandler: { placemarks, error in
            
            guard let placemark = placemarks?.first else { return }
            guard let targetCoordinate = placemark.location?.coordinate else { return }
            let pin = MKPointAnnotation()
            pin.coordinate = targetCoordinate
            pin.title = searchKeyword
            self.mapView.displayMapView.addAnnotation(pin)
            self.mapView.displayMapView.region = MKCoordinateRegionMakeWithDistance(targetCoordinate, 500, 500)
        })
        return true
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation as? MKUserLocation != self.mapView.displayMapView.userLocation else { return nil }
        var annotationView = self.mapView.displayMapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        }
        
        annotationView?.animatesDrop = true
        annotationView?.canShowCallout = true
        annotationView?.isDraggable = true
        
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let myLocation = locations.last else { return }
        let currentLocation = myLocation.coordinate
        
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let myRegion = MKCoordinateRegionMake(currentLocation, mySpan)
        
        mapView.displayMapView.setRegion(myRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("現在地の取得に失敗しました:\(error)")
    }
}
