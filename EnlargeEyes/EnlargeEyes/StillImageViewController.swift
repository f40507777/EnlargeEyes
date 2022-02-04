//
//  ViewController.swift
//  FaceFilter
//
//  Created by Finn on 2021/5/13.
//

import AVFoundation
import GPUImage
import UIKit
import Vision

class StillImageViewController: UIViewController {
    private let image = UIImage(named: "Lenna.jpeg")!
    private lazy var picture: PictureInput = PictureInput(image: image)
    private let filter = EnlargeEyesFilter()

    @IBOutlet var renderView: RenderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        picture --> filter --> renderView
        
        filter.intensity = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        faceDetection()
    }

    private func faceDetection() {
        guard let cgimage = image.cgImage else { return }
        let request = VNDetectFaceLandmarksRequest(completionHandler: handleFaces)
        let handler = VNImageRequestHandler(cgImage: cgimage, options: [:])
        do {
            try? handler.perform([request])
        }
    }

    private func handleFaces(request: VNRequest, error: Error?) {
        guard let faceDetectResults = request.results as? [VNFaceObservation] else {
            fatalError("Unexpected result type from VNDetectFaceRetanglesRequest.")
        }

        if faceDetectResults.count == 0 {
            print("No face detect.")
            return
        }

        drawFace(forObservations: faceDetectResults)
    }

    private func drawFace(forObservations observations: [VNFaceObservation]) {
        if let sublayers = renderView.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }

        for observation in observations {
            enlargeEyes(observation)
//            drawPoints(observation)
        }
    }

    @IBAction func intensityChange(_ sender: UISlider) {
        filter.intensity = sender.value - 0.5
        picture.processImage()
    }
}

extension StillImageViewController {
    private func enlargeEyes(_ observation: VNFaceObservation) {
        guard let landmarks = observation.landmarks else { return }
        var leftRadius: Float = 0
        var rightRadius: Float = 0

        if let leftPupilPoint = landmarks.leftPupil?.normalizedPoints.first,
           let leftEyePoints = landmarks.leftEye?.normalizedPoints {
            leftRadius = longestDistance(boundingBoxRect: observation.boundingBox, points: leftEyePoints) / 2
            filter.leftEyeCenterPosition = leftPupilPoint.getBoxPoint(boundingBoxRect: observation.boundingBox).position

        }

        if let rightPupilPoint = landmarks.rightPupil?.normalizedPoints.first,
           let rightEyePoints = landmarks.rightEye?.normalizedPoints {
            rightRadius = longestDistance(boundingBoxRect: observation.boundingBox, points: rightEyePoints) / 2
            filter.rightEyeCenterPosition = rightPupilPoint.getBoxPoint(boundingBoxRect: observation.boundingBox).position

        }
        let areaPlus: Float = 1.7
        filter.radius = Position(leftRadius * areaPlus, rightRadius * areaPlus)
        picture.processImage()
    }

    private func longestDistance(boundingBoxRect: CGRect, points: [CGPoint]) -> Float {
        var longestDistance: Float = 0
        for i in 0 ..< points.count - 1 {
            for j in 1 ..< points.count {
                longestDistance = max(longestDistance, distance(boundingBoxRect: boundingBoxRect, points[i], points[j]))
            }
        }

        return longestDistance
    }

    private func distance(boundingBoxRect: CGRect, _ lhs: CGPoint, _ rhs: CGPoint) -> Float {
        let l = lhs.getBoxPoint(boundingBoxRect: boundingBoxRect)
        let r = rhs.getBoxPoint(boundingBoxRect: boundingBoxRect)

        return sqrtf(pow(Float(l.x - r.x), 2) + pow(Float(l.y - r.y), 2))
    }
}

/*
 Draw the points on UIView

extension StillImageViewController {
    private func drawPoints(_ observation: VNFaceObservation) {
        guard let cgimage = image.cgImage else { return }
        let size = CGSize(width: cgimage.width, height: cgimage.height)
        let imageRect = AVMakeRect(aspectRatio: size, insideRect: renderView.bounds)
        let normalizedBoundingBoxRect = observation.boundingBox.normalizedFaceBoundingBox(imageRect: imageRect)

        drawFaceSharp(rect: normalizedBoundingBoxRect)
        drawLeftEyesPoints(observation, boundingRect: normalizedBoundingBoxRect)
        drawLeftPupil(observation, boundingRect: normalizedBoundingBoxRect)
        picture.processImage()
    }

    private func drawFaceSharp(rect: CGRect) {
        renderView.drawShape(color: .red, rect: rect)
    }

    private func drawLeftEyesPoints(_ observation: VNFaceObservation, boundingRect: CGRect) {
        if let landmarks = observation.landmarks,
           let leftEyes = landmarks.leftEye {
            for point in leftEyes.normalizedPoints {
                let normalizedPoint = point.normalizedLandmarkPoint(boundingBoxRect: boundingRect)
                renderView.drawPoint(color: .yellow, point: normalizedPoint)
            }
        }
    }

    private func drawLeftPupil(_ observation: VNFaceObservation, boundingRect: CGRect) {
        if let landmarks = observation.landmarks,
           let leftPupilPoint = landmarks.leftPupil?.normalizedPoints.first {
            let normalizedPoint = leftPupilPoint.normalizedLandmarkPoint(boundingBoxRect: boundingRect)
            renderView.drawPoint(color: .green, point: normalizedPoint)
        }
    }

    private func drawAllLandmarks(_ landmarks: VNFaceLandmarks2D?, boundingBoxRect: CGRect) {
        if let landmarks = landmarks, let allNormalizedPoints = landmarks.allPoints?.normalizedPoints {
            for point in allNormalizedPoints {
                let normalizedPoint = point.normalizedLandmarkPoint(boundingBoxRect: boundingBoxRect)
                renderView.drawPoint(color: .green, point: normalizedPoint)
            }
        }
    }

    private func centerPoint(_ target: VNFaceLandmarkRegion2D) -> CGPoint {
        let totalPoint = target.normalizedPoints.reduce(CGPoint(x: 0, y: 0), { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) })
        let count = CGFloat(target.normalizedPoints.count)
        let centerPoint = CGPoint(x: totalPoint.x / count, y: totalPoint.y / count)
        return centerPoint
    }

}

 */
