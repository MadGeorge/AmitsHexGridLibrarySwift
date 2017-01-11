import UIKit
import CoreGraphics
import PlaygroundSupport
import AmitsHexGrid

let _v = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
_v.backgroundColor = UIColor.black
PlaygroundPage.current.liveView = _v

extension Point {
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

extension UIBezierPath {
    convenience init(points: [Point], shouldBeClosed: Bool = true) {
        self.init()
        
        if let first = points.first {
            move(to: first.cgPoint)
        }
        
        for p in points[0..<points.count] {
            addLine(to: p.cgPoint)
        }
        
        if points.count > 1 && shouldBeClosed {
            close()
        }
    }
}

class DrawView: UIView {
    var hexes = [Hex]()
    var layout = HexLayout(orientation: Orientation.flat, size: Point(x: 25, y: 25), origin: Point(x: 150, y: 50))
    
    convenience init(frame: CGRect, layout: HexLayout) {
        self.init(frame: frame)
        
        self.layout = layout
    }
    
    func drawLabel(text: String, hexSize: Int, center: CGPoint) {
        let labelRect = CGRect(x: center.x - CGFloat((hexSize.double/2)), y: center.y - 5.0, width: CGFloat(hexSize), height: CGFloat(hexSize))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        NSString(string: text).draw(in: labelRect, withAttributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 8),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: paragraphStyle
        ])
    }
    
    func drawShapeRectangle(sizeW: Int, sizeH: Int) {
        hexes = [Hex]()
        
        let i1 = -floor(sizeW.double/2)
        let i2 = i1.int + sizeW
        let j1 = -floor(sizeH.double/2)
        let j2 = j1.int + sizeH
        
        for j in j1.int..<j2 {
            let jOffset = -floor(j.double/2)
            for i in (i1 + jOffset).int..<(i2.double + jOffset).int {
                if let hex = try? Hex(q: i, r: j) {
                    hexes.append(hex)
                    let points = layout.polygonCorners(for: hex)
                    let bz = UIBezierPath(points: points)
                    bz.stroke()
                    
                    let hexCenter = layout.centerPixel(for: hex).cgPoint
                    let labelText = hex.isRoot ? "q,r,s" : "\(hex.q),\(hex.r),\(hex.s)"
                    drawLabel(text: labelText, hexSize: 30, center: hexCenter)
                    
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.white.cgColor)
        ctx?.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        ctx?.setLineWidth(1)
        
        drawShapeRectangle(sizeW: 10, sizeH: 10)
    }
}

struct ViewDescription {
    let text: String
    let topOffset: CGFloat
    
    func makeLabel() -> UILabel {
        let l =  UILabel(frame: CGRect(x: 0, y: topOffset, width: 295, height: 20))
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white
        l.textAlignment = .right
        l.text = text
        return l
    }
}

let descriptions = [
    ViewDescription(text: "Pointy", topOffset: 5),
    ViewDescription(text: "Flat", topOffset: 140)
]

let pointyHexGrid = DrawView(frame: CGRect(x: 0, y: 30, width: 300, height: 100), layout: HexLayout(orientation: Orientation.pointy, size: Point(x: 25, y: 25), origin: Point(x: 90, y: 50)))
let flatHexGrid = DrawView(frame: CGRect(x: 0, y: 160, width: 300, height: 100))

_v.addSubview(pointyHexGrid)
_v.addSubview(flatHexGrid)

for descr in descriptions {
    _v.addSubview(descr.makeLabel())
}
