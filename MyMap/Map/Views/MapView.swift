import UIKit
import MapKit

class MapView: UIView {

    static let nibName = String(describing: MapView.self)
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var displayMapView: MKMapView!
}
