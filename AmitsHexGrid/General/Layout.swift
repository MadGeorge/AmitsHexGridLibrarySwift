//
//  Layout.swift
//  AmitsHexGrid
//
//  Created by MadGeorge on 11/01/2017.
//  Copyright © 2017 MadGeorge. All rights reserved.
//

import Foundation

/// Structure for pointy top/flat conversions
public struct Orientation {
    /// Matrix for pointy top/flat conversions
    let f0, f1, f2, f3: Double
    
    /// Invers matrix for pointy top/flat conversions
    let bo, b1, b2, b3: Double
    
    /// Pointy top hexagons starts at 30° and flat top starts at 0°
    public let startAngle: Double
    
    public static let pointy = Orientation(
        f0: sqrt(3.0), f1: sqrt(3.0)/2, f2: 0.0, f3: 3.0/2.0,
        bo: sqrt(3.0) / 3.0, b1: -1.0, b2: 0.0, b3: 2.0/3.0,
        startAngle: 0.5
    )
    
    public static let flat = Orientation(
        f0: 3.0 / 2.0, f1: 0.0, f2: sqrt(3.0) / 2.0, f3: sqrt(3.0),
        bo: 2.0 / 3.0, b1: 0.0, b2: -1.0/3.0, b3: sqrt(3.0) / 3.0,
        startAngle: 0.0
    )
}

public struct HexLayout {
    public let orientation: Orientation
    public let size: Point
    
    /// Center of the hexagon
    public let origin: Point
    
    public init(orientation: Orientation, size: Point, origin: Point) {
        self.orientation = orientation
        self.size = size
        self.origin = origin
    }
    
    // TODO: pixel_to_hex
    
}

/**
 Struct to hold two dimensional vectors
 
 **Note:** CGPoint do not used to minimise dependency
 */
public struct Point {
    public let x, y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

// Drawing
extension HexLayout {
    public func centerPixel(for hex: Hex) -> Point {
        let m = orientation
        let x = ((m.f0 * hex.q.double) + (m.f1 * hex.r.double)) * size.x
        let y = ((m.f2 * hex.q.double) + (m.f3 * hex.r.double)) * size.y
        
        return Point(x: x + origin.x, y: y + origin.y)
    }
    
    public func hexCornerOffset(at index: Int) -> Point {
        let angle = 2.0 * M_PI * (orientation.startAngle + index.double) / 6
        return Point(x: size.x * cos(angle), y: size.y * sin(angle))
    }
    
    public func polygonCorners(for hex: Hex) -> [Point] {
        var corners = [Point]()
        
        let center = centerPixel(for: hex)
        for i in 0...5 {
            let offset = hexCornerOffset(at: i)
            corners.append(Point(x: center.x + offset.x, y: center.y + offset.y))
        }
        
        return corners
    }
}
