import Foundation

/**
 Structure to represent cube coordinates
 
 **Note:** q,r,s is the same as x,y,z.
 s is zero by default and you can use it if you need Axial coordinate
 storage over Cube. 
 
 Under the hood this structure uses Cube coordinates and convert back
 and forth to Axial coordinates
 
 */
public struct Hex {
    public let q, r, s: Int
    
    // Precompute the permutations
    // http://www.redblobgames.com/grids/hexagons/#neighbors
    static let directions: [Hex] =  [
        try! Hex(q:  1,  r:  0,  s: -1),
        try! Hex(q:  1,  r: -1,  s:  0),
        try! Hex(q:  0,  r: -1,  s:  1),
        try! Hex(q: -1,  r:  0,  s:  1),
        try! Hex(q: -1,  r:  1,  s:  0),
        try! Hex(q:  0,  r:  1,  s: -1),
    ]
    
    /// Cube coordinate system initializer
    public init(q: Int, r: Int, s: Int) throws {
        self.q = q
        self.r = r
        self.s = s
        
        if (q + r + s) != 0 {
            throw InvalidArguments(message: "Sum of coordinates should be zero")
        }
    }
    
    /// Axial coordinate system initializer
    public init(q: Int, r: Int) throws {
        try self.init(q: q, r: r, s: -q - r)
    }
    
    public struct InvalidArguments: Error {
        var message: String
    }
}

extension Hex: Equatable {
    public static func ==(lhs: Hex, rhs: Hex) -> Bool {
        lhs.q == rhs.q && lhs.r == rhs.r && lhs.s == rhs.s
    }
}

// Coordinate arithmetic
extension Hex {
    // If two hex are valid, produced hex operation will be valid, we can unwrap explicitly
    
    public func add(hex: Hex) -> Hex {
        try! Hex(q: q + hex.q, r: r + hex.r, s: s + hex.s)
    }
    
    public func subtract(hex: Hex) -> Hex {
        try! Hex(q: q - hex.q, r: r - hex.r, s: s - hex.s)
    }
    
    public func multiply(by k: Int) -> Hex {
        try! Hex(q: q * k, r: r * k, s: s * k)
    }
}

// Distance
extension Hex {
    /// Hexagon length in grid units
    public var length: Int {
        (abs(q) + abs(r) + abs(s)) / 2
    }
    
    /// Distance from to target hexagon in grid units
    public func distance(to hex: Hex) -> Int {
        self.subtract(hex: hex).length
    }
}

// Neighbors
extension Hex {
    /**     
     - Parameter index: direction Integer from 0 to 5
     - Returns Hexagon neighbor to current one
     */
    public func direction(at index: Int) -> Hex {
        // hah! what is this?
        // This is math magic to make it work with index outside of 0...5
        Hex.directions[(6 + (index % 6)) % 6]
    }
    
    public func neighbor(at index: Int) -> Hex {
        add(hex: direction(at: index))
    }
}

// Helpers 
extension Hex {
    public var isRoot: Bool {
        q == 0 && r == 0 && s == 0
    }
}
