import Foundation
import GameplayKit

extension Hex {
    init(v: int3) throws {
        let x = Int(v.x)
        let y = Int(v.y)
        try self.init(q: x, r: y, s: -x - y)
    }
}
