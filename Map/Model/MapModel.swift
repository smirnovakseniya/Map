//
//  MapModel.swift
//  Map
//
//  Created by Kseniya Smirnova on 19.10.22.
//

import UIKit
import MapKit

class MapModel {
    
    //MARK: - Variables
    
    weak var timer: Timer?
    
    var flightpathPolylineLast: MKGeodesicPolyline!
    var flightpathPolylineNext: MKGeodesicPolyline!
    var planeAnnotation: MKPointAnnotation!
    var planeAnnotationPosition = 0
    let annotation = MKPointAnnotation()
    var planeDirection: CLLocationDirection?
    
    var isHiddenPath = false
    
    let path = Path(pointStart: CLLocationCoordinate2D(latitude: 53.893009, longitude: 27.567444),
                    pointFinish: CLLocationCoordinate2D(latitude: 36.806389, longitude: 10.181667),
                    info: InfoPath(date: "01.10.2022", name: "Минск - Тунис", info: "Какая-то еще информация..."))
    
    //MARK: - Functions
    
    func addPolyline(mapView: MKMapView) {
        flightpathPolylineLast = createPolyline(mapView: mapView, point1: path.pointStart, point2: path.pointFinish)
        planeAnnotation = annotation
        updatePlanePositionLast(mapView: mapView)
        mapView.addAnnotation(annotation)
        mapView.addOverlay(flightpathPolylineLast)
    }
    
    func tapToPlane(mapView: MKMapView) -> InfoPath {
        isHiddenPath = true
        flightpathPolylineLast = createPolyline(mapView: mapView, point1: path.pointStart, point2: path.pointFinish)
        updatePlanePositionLast(mapView: mapView)
        mapView.addOverlay(flightpathPolylineLast)
        return path.info
    }
    
    func closedSheet(mapView: MKMapView) {
        isHiddenPath = false
        mapView.removeOverlays(mapView.overlays)
    }
    
    func isHiddenPathStatus(mapView: MKMapView, overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else { return  MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: polyline)
        if isHiddenPath {
            if polyline == flightpathPolylineLast {
                renderer.lineWidth = 3.0
                renderer.strokeColor = .red
            } else {
                renderer.lineWidth = 3.0
                renderer.strokeColor = .blue
            }
        } else {
            mapView.removeOverlays(mapView.overlays)
        }
        return renderer
    }
    
    private func updatePlanePositionLast(mapView: MKMapView) {
        let step = 1
        if planeAnnotationPosition + step < flightpathPolylineLast.pointCount {
            
            let points = flightpathPolylineLast.points()
            let previousMapPoint = points[planeAnnotationPosition]
            
            planeAnnotationPosition += step
            
            let nextMapPoint = points[planeAnnotationPosition]
            
            planeAnnotation.coordinate = nextMapPoint.coordinate
            
            flightpathPolylineNext = createPolyline(mapView: mapView, point1: path.pointStart, point2: planeAnnotation.coordinate)
            
            mapView.addOverlay(flightpathPolylineNext)
            
            planeDirection = directionBetweenPoints(sourcePoint: previousMapPoint, nextMapPoint)
            planeAnnotation.coordinate = nextMapPoint.coordinate
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                self.updatePlanePositionLast(mapView: mapView)
            }
        } else {
            timer?.invalidate()
        }
    }
    
    private func createPolyline(mapView: MKMapView, point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> MKGeodesicPolyline {
        let locations = [point1, point2]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: locations, count: locations.count)
        return geodesicPolyline
    }
    
    //MARK: - Degrees
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi - .pi
    }
    private func directionBetweenPoints(sourcePoint: MKMapPoint, _ destinationPoint: MKMapPoint) -> CLLocationDirection {
        let x = destinationPoint.x - sourcePoint.x
        let y = destinationPoint.y - sourcePoint.y
        return radiansToDegrees(atan2(y, x)).truncatingRemainder(dividingBy: 360)
    }
}
