import UIKit
import MapKit

class MapViewController: UIViewController {

    var mapView: MapView!
    
    override func loadView() {
        let nib = UINib(nibName: MapView.nibName, bundle: nil)
        mapView = nib.instantiate(withOwner: nil, options: nil).first as! MapView
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.textField.delegate = self
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
