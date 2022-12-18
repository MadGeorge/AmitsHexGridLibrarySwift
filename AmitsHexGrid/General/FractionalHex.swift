import Foundation

/// Same as hex but for floating point values
struct FractionalHex {
    public let q, r, s: Double

    func hex() throws -> Hex {
        var q = round(self.q)
        var r = round(self.r)
        var s = round(self.s)

        let q_diff = abs(q - self.q)
        let r_diff = abs(r - self.r)
        let s_diff = abs(s - self.s)

        if (q_diff > r_diff && q_diff > s_diff) {
            q = -r - s
        } else if (r_diff > s_diff) {
            r = -q - s
        } else {
            s = -q - r
        }

        return try .init(q: Int(q), r: Int(r), s: Int(s))
    }
}
