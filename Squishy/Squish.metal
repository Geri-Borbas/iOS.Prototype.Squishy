//
//  Squish.metal
//  Squishy
//
//  Created by Personal on 11/05/2024.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] float2 squish(float2 position, float2 controlPoint) {
    return position - (controlPoint * 0.5);
}
