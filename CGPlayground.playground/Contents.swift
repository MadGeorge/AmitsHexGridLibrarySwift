//: A UIKit based Playground for presenting user interface

import Foundation
import CoreGraphics
import UIKit
import PlaygroundSupport
import AmitsHexGrid

extension Point {
    var cgPoint: CGPoint {
        .init(x: x, y: y)
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
    private var hexes = [Hex]()
    private let layout: HexLayout
    private var selectionView = UIView()

    required init(frame: CGRect, layout: HexLayout, customGrid: [Hex] = []) {
        self.layout = layout
        self.hexes = customGrid

        super.init(frame: frame)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(gesture)

        backgroundColor = .red

        addSubview(selectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawLabel(text: String, hexSize: Int, center: CGPoint) {
        let labelRect = CGRect(
            x: center.x - CGFloat((hexSize.double/2)),
            y: center.y - 5.0, width: CGFloat(hexSize), height: CGFloat(hexSize)
        )

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        NSString(string: text).draw(in: labelRect, withAttributes: [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ])
    }

    func drawShapeHexagon(radius: Int) {
        hexes = [Hex]()

        for q in -radius...radius {
            let r1 = max(-radius, (-q - radius))
            let r2 = min(radius, (-q + radius))

            for r in r1...r2 {
                if let hex = try? Hex(q: q, r: r) {
                    hexes.append(hex)
                    draw(hex)
                }
            }
        }
    }

    func drawShapeRectangle(sizeW: Int, sizeH: Int) {
        hexes = [Hex]()

        let i1 = -floor(sizeW.double / 2)
        let i2 = i1.int + sizeW
        let j1 = -floor(sizeH.double / 2)
        let j2 = j1.int + sizeH

        for j in j1.int..<j2 {
            let jOffset = -floor(j.double / 2)
            for i in (i1 + jOffset).int..<(i2.double + jOffset).int {
                if let hex = try? Hex(q: i, r: j) {
                    hexes.append(hex)
                    draw(hex)
                }
            }
        }
    }

    func drawCustom() {
        for hex in hexes {
            draw(hex)
        }
    }

    func draw(_ hex: Hex) {
        let points = layout.polygonCorners(for: hex)
        let bz = UIBezierPath(points: points)
        bz.stroke()

        let hexCenter = layout.centerPixel(for: hex).cgPoint
        let labelText = hex.isRoot ? "q,r,s" : "\(hex.q),\(hex.r),\(hex.s)"
        drawLabel(text: labelText, hexSize: 30, center: hexCenter)
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        ctx.setLineWidth(1)

        if hexes.isEmpty {
            drawShapeHexagon(radius: 2)
            // drawShapeRectangle(sizeW: 2, sizeH: 2)
        } else {
            drawCustom()
        }
    }

    @objc func tap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)

        do {
            let hex = try layout.hex(at: .init(x: point.x, y: point.y))

            selectionView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

            let shape = CAShapeLayer()
            shape.path = UIBezierPath(points: layout.polygonCorners(for: hex)).cgPath
            shape.strokeColor = nil
            shape.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
            selectionView.layer.insertSublayer(shape, at: .zero)

        } catch {
            print(error)
        }
    }
}

struct ViewDescription {
    let text: String
    let topOffset: CGFloat

    func makeLabel() -> UILabel {
        let l =  UILabel(frame: CGRect(x: 0, y: topOffset, width: 295, height: 20))
        l.font = .systemFont(ofSize: 14)
        l.textColor = .white
        l.textAlignment = .right
        l.text = text
        return l
    }
}

// Render views

let pointyHexGrid = DrawView(
    frame: CGRect(x: 0, y: 30, width: 300, height: 200),
    layout: .init(
        orientation: .pointy,
        size: Point(x: 25, y: 25),
        origin: Point(x: 150, y: 100)
    )
)

pointyHexGrid.addSubview(ViewDescription(text: "Pointy", topOffset: 5).makeLabel())

let flatHexGrid = DrawView(
    frame: CGRect(x: 0, y: 260, width: 300, height: 260),
    layout: .init(
        orientation: .flat,
        size: .init(x: 25, y: 25),
        origin: .init(x: 150, y: 120)
    )
)

flatHexGrid.addSubview(ViewDescription(text: "Flat", topOffset: 5).makeLabel())

let pointyCustomGrid = DrawView(
    frame: CGRect(x: 0, y: 550, width: 300, height: 160),
    layout: .init(
        orientation: .pointy,
        size: Point(x: 25, y: 25),
        origin: Point(x: 150, y: 80)
    ),
    customGrid: [
        try! .init(q: -1, r: -1, s: +2),
        try! .init(q: 00, r: -1, s: +1),
        try! .init(q: +1, r: -1, s: 00),
        try! .init(q: +2, r: -1, s: -1),
        try! .init(q: -1, r: 00, s: +1),
        try! .init(q: 00, r: 00, s: 00),
        try! .init(q: +1, r: 00, s: -1),
        try! .init(q: -2, r: +1, s: +1),
        try! .init(q: -1, r: +1, s: 00),
        try! .init(q: 00, r: +1, s: -1),
        try! .init(q: +1, r: +1, s: -2),
    ]
)

pointyCustomGrid.addSubview(ViewDescription(text: "Pointy Custom", topOffset: 5).makeLabel())

let _v = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 800))
_v.backgroundColor = UIColor.black
PlaygroundPage.current.liveView = _v

_v.addSubview(pointyHexGrid)
_v.addSubview(flatHexGrid)
_v.addSubview(pointyCustomGrid)
