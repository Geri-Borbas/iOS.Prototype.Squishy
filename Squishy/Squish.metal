//
//  Squish.metal
//  Squishy
//
//  Created by Geri on 11/05/2024.
//

#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] float2 squish(
                               float2 position,
                               float2 layerSize,
                               float2 anchorPoint,
                               float2 controlPoint
                               ) {
    float distance = length(position - anchorPoint);
    float weight = (distance) / length(layerSize);
    return position - (controlPoint * weight);
}

[[ stitchable ]] float2 gaussianSquish(
                                       float2 position,
                                       float2 layerSize,
                                       float2 anchorPoint,
                                       float2 controlPoint
                                       ) {
    float distance = length(position - anchorPoint);
    float sigma = length(layerSize) * 0.3;
    float weight = exp(-(distance * distance) / (2.0 * sigma * sigma));
    return position - (controlPoint * weight);
}
