//
//  MapModel.swift
//  Map
//
//  Created by Kseniya Smirnova on 19.10.22.
//

import UIKit
import MapKit

class MapModel {
    
    weak var timer: Timer?
    
    var flightpathPolylineLast: MKGeodesicPolyline!
    var flightpathPolylineNext: MKGeodesicPolyline!
    var planeAnnotation: MKPointAnnotation!
    var planeAnnotationPosition = 0
    let annotation = MKPointAnnotation()
    var isHiddenPath = false
     
    let point1 = CLLocationCoordinate2D(latitude: 53.893009, longitude: 27.567444) // Минск
    let point2 = CLLocationCoordinate2D(latitude: 52.097622, longitude: 23.734051) // Брест
    //        let point3 = CLLocationCoordinate2D(latitude: 54.687157, longitude: 25.279652)
    
    func addPolyline(mapView: MKMapView) {
        flightpathPolylineLast = createPolyline(mapView: mapView, point1: point1, point2: point2)
        planeAnnotation = annotation
        updatePlanePositionLast(mapView: mapView)
        mapView.addAnnotation(annotation)
        mapView.addOverlay(flightpathPolylineLast)
    }
    func tapToPlane(mapView: MKMapView) {
        isHiddenPath.toggle()
        if isHiddenPath {
            flightpathPolylineLast = createPolyline(mapView: mapView, point1: point1, point2: point2)
            updatePlanePositionLast(mapView: mapView)
            mapView.addOverlay(flightpathPolylineLast)
        } else {
            mapView.removeOverlays(mapView.overlays)
        }
    }
    
    func updatePlanePositionLast(mapView: MKMapView) {
        let step = 1
        if planeAnnotationPosition + step < flightpathPolylineLast.pointCount {
//            mapView.removeAnnotation(annotation)
            let points = flightpathPolylineLast.points()
            self.planeAnnotationPosition += step
            let nextMapPoint = points[planeAnnotationPosition]
            planeAnnotation.coordinate = nextMapPoint.coordinate
            flightpathPolylineNext = createPolyline(mapView: mapView, point1: point1, point2: planeAnnotation.coordinate)
            mapView.addOverlay(flightpathPolylineNext)
            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: false) { _ in
                self.updatePlanePositionLast(mapView: mapView)
//                mapView.addAnnotation(self.annotation)
            } //  perform(#selector(updatePlanePositionLast), with: nil, afterDelay: 0.03)
        } else {
            timer?.invalidate()
        }
    }
    
    func createPolyline(mapView: MKMapView, point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> MKGeodesicPolyline {
        let locations = [point1, point2]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: locations, count: locations.count)
        return geodesicPolyline
    }
    
    //MARK: - Degrees
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi - .pi
    }
    func getBearingBetweenTwoPoints(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
        let lat1 = degreesToRadians(point1.latitude)
        let lon1 = degreesToRadians(point1.longitude)

        let lat2 = degreesToRadians(point2.latitude)
        let lon2 = degreesToRadians(point2.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansToDegrees(radiansBearing)
    }
    
    func addPoints() -> Double {
        return getBearingBetweenTwoPoints(point1: point1, point2: point2)
    }
    
}
