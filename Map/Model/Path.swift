//
//  Path.swift
//  Map
//
//  Created by Kseniya Smirnova on 21.10.22.
//

import MapKit

struct Path {
    let pointStart: CLLocationCoordinate2D
    let pointFinish: CLLocationCoordinate2D
    let info: InfoPath
}

struct InfoPath {
    let date: String
    let name: String
    let info: String
}
