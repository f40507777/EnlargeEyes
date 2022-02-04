//
//  EnlargeEyes.metal
//  GPUImage_iOS
//
//  Created by Finn on 2021/5/23.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
#include "OperationShaderTypes.h"

using namespace metal;

typedef struct {
    float intensity;
    float2 radius;
    float2 leftEyeCenterPosition;
    float2 rightEyeCenterPosition;

} EnlargeEyesUniform;

float2 enlargePosition(float2 currentPosition, float2 centerPosition, float currentDistance, float radius, float intensity);

fragment half4 enlargeEyesFragment(SingleInputVertexIO          fragmentInput [[stage_in]],
                                   texture2d < half >           inputTexture [[texture(0)]],
                                   constant EnlargeEyesUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    // 獲取當前的位置 (x, y)
    float2 currentPosition = fragmentInput.textureCoordinate;
    
    // 左眼中心位置 (x, y)
    float2 leftCenterPosition = uniform.leftEyeCenterPosition;
    
    // 當前位置與眼睛中心距離
    float leftDistance = distance(leftCenterPosition, currentPosition);
    
    // 檢查是否在左眼半徑內 (radius.x 為左眼)
    if (leftDistance < uniform.radius.x) {
        
        // 在半徑內則將當前位置取代繪製的位置
        currentPosition = enlargePosition(currentPosition, leftCenterPosition, leftDistance, uniform.radius.x, uniform.intensity);
    }

    // 右眼以此類推
    float2 rightCenterPosition = uniform.rightEyeCenterPosition;
    
    float rightDistance = distance(rightCenterPosition, currentPosition);
    if (rightDistance < uniform.radius.y) {
        currentPosition = enlargePosition(currentPosition, rightCenterPosition, rightDistance, uniform.radius.y, uniform.intensity);
    }
       
    // 取得位置顏色並回傳
    half4 color = inputTexture.sample(quadSampler, currentPosition);
    return half4(color.rgb, 1.0);
}

float2 enlargePosition(float2 currentPosition, float2 centerPosition, float currentDistance, float radius, float intensity) {
    
    // intensity > 0 會使 weight < 1，亦然反之
    float weight = (1 - pow((currentDistance / radius - 1), 2) * intensity);
    
    // weight < 1 會回傳離中心較近的距離
    return centerPosition + (currentPosition - centerPosition) * weight;
}

