//
//  CameraViewController.swift
//  FaceFilter
//
//  Created by finn on 2021/12/4.
//

import UIKit
import GPUImage
import Vision
import AVFoundation

class CameraViewController: UIViewController {

    private lazy var camera: Camera? = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        guard let device = deviceDiscoverySession.devices.first else { return nil}
        return try? Camera(sessionPreset: .hd1280x720, cameraDevice: device, location: .frontFacing, orientation: .none, captureAsYUV: true)
    }()
    
    private let filter = EnlargeEyesFilter()
    @IBOutlet var renderView: RenderView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
            if response {
                self?.setupCamera()
            }
        }
        
    }
    
    private func setupCamera() {
        guard let camera = camera else { return }
        camera --> filter --> renderView
        camera.delegate = self

        filter.intensity = 0
        camera.startCapture()

    }

    @IBAction func intensityChange(_ sender: UISlider) {
        filter.intensity = sender.value - 0.5
    }
}

extension CameraViewController: CameraDelegate {
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest(completionHandler: handleFaces)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        do {
            try? handler.perform([request])
        }
    }
    
}

extension CameraViewController {
    private func handleFaces(request: VNRequest, error: Error?) {
        guard let faceDetectResults = request.results as? [VNFaceObservation] else {
            fatalError("Unexpected result type from VNDetectFaceRetanglesRequest.")
        }

        if faceDetectResults.count == 0 {
            return
        }

        DispatchQueue.main.async {
            self.addSharpToFace(forObservations: faceDetectResults)
        }
    }
    
    private func addSharpToFace(forObservations observations: [VNFaceObservation]) {
        if let sublayers = renderView.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        
        for observation in observations {
            enlargeEyes(observation)
        }
        
    }
    
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
