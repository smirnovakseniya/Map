//
//  MapVC.swift
//  Map
//
//  Created by Kseniya Smirnova on 17.10.22.
//

import UIKit
import MapKit

class MapVC: UIViewController, UIViewControllerTransitioningDelegate, InfoVCDelegate {
    func update(text: Bool) {
        model.isHiddenPath = text
    }
    
    private let model = MapModel()
    private let infoVC = InfoVC()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        model.addPolyline(mapView: mapView)
        
        
        infoVC.delegate = self
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let planeIdentifier = "Plane"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: planeIdentifier)
        ?? MKAnnotationView(annotation: annotation, reuseIdentifier: planeIdentifier)
        annotationView.image = UIImage(systemName: "airplane")
        annotationView.transform = CGAffineTransformRotate(mapView.transform, model.addPoints())
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        model.tapToPlane(mapView: mapView)
        
        if #available(iOS 15.0, *) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "infoVC")
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }
            self.present(viewController, animated: true, completion: nil)
        }
//            else {
//            let yourVC = ViewController()
//            yourVC.modalPresentationStyle = .custom
//            yourVC.transitioningDelegate = self
//            self.present(yourVC, animated: true)
//        }
        /// аннотация, на которую было нажата, держалась выбранной. код ниже отменяет выбор аннотации, и после этого можно нажать во второй раз.
        DispatchQueue.main.async {
            for item in self.mapView.selectedAnnotations {
                self.mapView.deselectAnnotation(item, animated: false)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: polyline)
        
        if model.isHiddenPath {
            if polyline == model.flightpathPolylineLast {
                renderer.lineWidth = 2.0
                renderer.strokeColor = .red
            } else {
                renderer.lineWidth = 2.0
                renderer.strokeColor = .blue
            }
        } else {
            mapView.removeOverlays(mapView.overlays)
        }
        return renderer
    }
}

class MyAnnotation: NSObject,MKAnnotation {

var info : String
var coordinate : CLLocationCoordinate2D

init(coordinate: CLLocationCoordinate2D, info: String) {
    self.coordinate = coordinate
    self.info = info
}
}
