//
//  CGPoint+Extensions.swift
//  FaceFilter
//
//  Created by Finn on 2021/5/23.
//

import Foundation
import UIKit
import GPUImage
import Vision

extension CGPoint {
    var position: Position {
        return Position(Float(self.x), Float(self.y))
    }
    
    func normalizedLandmarkPoint(boundingBoxRect: CGRect) -> CGPoint {
        let updatedPoint = CGPoint(x: x, y: 1 - y)
        let point = VNImagePointForNormalizedPoint(updatedPoint, Int(boundingBoxRect.size.width), Int(boundingBoxRect.size.height))
        return CGPoint(x: boundingBoxRect.minX + point.x, y: boundingBoxRect.minY + point.y)
    }
    
    func getBoxPoint(boundingBoxRect: CGRect) -> CGPoint {
        return CGPoint(x: boundingBoxRect.minX + boundingBoxRect.width * x,
                       y: boundingBoxRect.adjustPoint.y + boundingBoxRect.height * (1 - y))
    }

}




//extension CGRect {
//    // 透過 image rect 將 boundingBox 轉為 UIView 座標系
//    func normalizedFaceBoundingBox(imageRect: CGRect) -> CGRect {
//        let rect = CGRect(x: minX, y: 1 - maxY, width: width, height: height)
//        let newRect = VNImageRectForNormalizedRect(rect, Int(imageRect.width), Int(imageRect.height))
//        return CGRect(origin: CGPoint(x: newRect.minX, y: newRect.minY + imageRect.minY), size: newRect.size)
//    }
//}
//
//extension CGPoint {
//    // 透過 boundingBox rect (UIView座標系) 將 landmark point 轉為 UIView 座標系
//    func normalizedLandmarkPoint(boundingBoxRect: CGRect) -> CGPoint {
//        let updatedPoint = CGPoint(x: x, y: 1 - y)
//        let point = VNImagePointForNormalizedPoint(updatedPoint, Int(boundingBoxRect.size.width), Int(boundingBoxRect.size.height))
//        return CGPoint(x: boundingBoxRect.minX + point.x, y: boundingBoxRect.minY + point.y)
//    }
//}



