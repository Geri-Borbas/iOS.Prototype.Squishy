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
                               float2 layerCenter,
                               float2 anchorPoint,
                               float2 controlPoint,
                               float multiplier
                               ) {
    float distance = length(position - anchorPoint);
    float weight = (distance) / length(layerCenter);
    return position - (controlPoint * weight * multiplier);
}

[[ stitchable ]] float2 cubicSquish(
                               float2 position,
                               float2 layerCenter,
                               float2 anchorPoint,
                               float2 controlPoint,
                               float multiplier
                               ) {
    float distance = length(position - anchorPoint);
    float weight = (distance) / length(layerCenter);
    return position - (controlPoint * (weight * weight) * multiplier);
}

[[ stitchable ]] float2 gaussianSquish(
                                       float2 position,
                                       float2 layerCenter,
                                       float2 anchorPoint,
                                       float2 controlPoint,
                                       float multiplier
                                       ) {
    float distance = length(position - anchorPoint);
    float sigma = length(layerCenter) * multiplier;
    float weight = 1.0 - exp(-(distance * distance) / (2.0 * sigma * sigma));
    return position - (controlPoint * weight);
}
