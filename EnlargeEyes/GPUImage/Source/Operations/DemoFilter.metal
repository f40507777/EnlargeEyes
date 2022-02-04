#include <metal_stdlib>
#include "OperationShaderTypes.h"

using namespace metal;

// 定義 uniform data struct
typedef struct
{
    // float2 表示有兩個 range 有兩個 float 組成, 第一個為x, 第二個為y
    float2 range;
} RangeUniform;

// Fragment shader 需要回傳該 pixel 所需要顯示的顏色 half(R, G, B, A)
fragment half4 demoFilter(SingleInputVertexIO fragmentInput [[stage_in]],
                          texture2d<half> inputTexture [[texture(0)]],
                          constant RangeUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    
    // 可以透過 fragmentInput.textureCoordinate 來獲取當前 fragment 執行的 pixel 位置
    float2 currentPosition = fragmentInput.textureCoordinate;
    
    // 可以使用由外部帶入的參數 uniform.range
    if(currentPosition.x <= uniform.range.x && currentPosition.y <= uniform.range.y) {
        
        // 將範圍內指定顏色為藍色 (R, G, B, A)
        return half4(0.0, 0.0, 1.0, 1.0);
    }
    
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).rgba;
    return color;
}
