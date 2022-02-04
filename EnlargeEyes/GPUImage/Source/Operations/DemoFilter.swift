//
//  DemoFilter.swift
//  GPUImage_iOS
//
//  Created by finn on 2022/1/17.
//  Copyright © 2022 Red Queen Coder, LLC. All rights reserved.
//

import Foundation

public class DemoFilter: BasicOperation {
    // 透過 uniform settings 來帶入參數
    // Position類型是由三個 float 組成，GPUImage3 會自動轉換為 float3 格式
    public var range: Position = .zero { didSet { uniformSettings["range"] = range } }

    public init() {
        // 可以指定使用哪個 fragment shader
        super.init(fragmentFunctionName: "demoFilter")
        
        ({ range = .zero })()
    }
}
