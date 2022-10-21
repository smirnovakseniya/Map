//
//  MapVC.swift
//  Map
//
//  Created by Kseniya Smirnova on 17.10.22.
//

import UIKit
import MapKit


class MapVC: UIViewController, UIViewControllerTransitioningDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Variables
    
    private let model = MapModel()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.addPolyline(mapView: mapView)
    }
}

//MARK: - Extension MapView

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let planeIdentifier = "Plane"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: planeIdentifier)
        ?? MKAnnotationView(annotation: annotation, reuseIdentifier: planeIdentifier)
        annotationView.image = UIImage(systemName: "airplane")
        annotationView.transform = CGAffineTransformRotate(mapView.transform, model.degreesToRadians(model.planeDirection!))
        return annotationView
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        show(InfoVC.initialization(model.tapToPlane(mapView: mapView), delegate: self), sender: nil)
//        present(InfoVC.initialization(model.tapToPlane(mapView: mapView), delegate: self), animated: true, completion: nil)
        DispatchQueue.main.async {
            for item in self.mapView.selectedAnnotations {
                self.mapView.deselectAnnotation(item, animated: false)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return model.isHiddenPathStatus(mapView: mapView, overlay: overlay)
    }
}

//MARK: - Extension MapVC

extension MapVC: InfoVCDelegate {
    func update(text: Bool) {
        model.closedSheet(mapView: mapView)
    }
}
