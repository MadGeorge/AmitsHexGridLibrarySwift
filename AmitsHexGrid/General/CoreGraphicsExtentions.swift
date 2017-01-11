import Foundation
import CoreGraphics

extension Hex {
    init(v: CGVector) throws {
        let x = Int(v.dx)
        let y = Int(v.dy)
        try self.init(q: x, r: y, s: -x - y)
    }
}
