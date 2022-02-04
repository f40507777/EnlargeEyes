//
//  EnlargeEyes.swift
//  GPUImage_iOS
//
//  Created by Finn on 2021/5/23.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

import Foundation

public class EnlargeEyesFilter: BasicOperation {
    public var intensity: Float = 0.03 {
        didSet {
            uniformSettings["intensity"] = intensity
        }
    }
    
    public var radius: Position = .zero {
        didSet {
            uniformSettings["radius"] = radius
        }
    }
    
    public var leftEyeCenterPosition: Position = .zero {
        didSet {
            uniformSettings["leftEyeCenterPosition"] = leftEyeCenterPosition
        }
    }
    
    public var rightEyeCenterPosition: Position = .zero {
        didSet {
            uniformSettings["rightEyeCenterPosition"] = rightEyeCenterPosition
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "enlargeEyesFragment")

        ({ intensity = 0.0 })()
        ({ radius = .zero })()
        ({ leftEyeCenterPosition = .zero })()
        ({ rightEyeCenterPosition = .zero })()
    }
}
