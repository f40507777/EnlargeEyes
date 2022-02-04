//
//  UIView+Extension.swift
//  FaceFilter
//
//  Created by finn on 2021/11/28.
//

import Foundation
import UIKit

extension UIView {
    func drawShape(color: UIColor, rect: CGRect) {
        let layer = CAShapeLayer()
        layer.frame = rect
        layer.borderColor = color.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 3
        self.layer.addSublayer(layer)
    }

    func drawPaths(color: UIColor, points: [CGPoint]) {
        let layer = CAShapeLayer()
        let graduationPath = UIBezierPath()
        for (index, element) in points.enumerated() {
            if index == 0 {
                graduationPath.move(to: element)
                continue
            }
            graduationPath.addLine(to: element)
        }

        layer.path = graduationPath.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = 2.0
        self.layer.addSublayer(layer)
    }
    
    func drawPoint(color: UIColor, point: CGPoint) {

        let path = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: 3, height: 3)))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = color.cgColor
        
        self.layer.addSublayer(shapeLayer)
    }
}
