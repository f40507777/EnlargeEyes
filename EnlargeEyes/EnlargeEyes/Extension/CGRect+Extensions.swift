//
//  CGRect+Extensions.swift
//  FaceFilter
//
//  Created by Finn on 2021/5/23.
//

import Foundation
import UIKit
import Vision

extension CGRect {
    var adjustPoint: CGPoint {
        return CGPoint(x: origin.x, y: 1 - origin.y - height)
    }
    
    func normalizedFaceBoundingBox(imageRect: CGRect) -> CGRect {
        let rect = CGRect(x: minX, y: 1 - maxY, width: width, height: height)
        let newRect = VNImageRectForNormalizedRect(rect, Int(imageRect.width), Int(imageRect.height))
        return CGRect(origin: CGPoint(x: newRect.minX, y: newRect.minY + imageRect.minY), size: newRect.size)
    }
}
