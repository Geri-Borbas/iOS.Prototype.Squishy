//
//  ContentView.swift
//  Squishy
//
//  Created by Personal on 11/05/2024.
//

import SwiftUI

struct ContentView: View {

    // Dot position.
    @State var isDragging = false
    @State var dotDragStartPosition = CGPoint.zero
    @State var dotDragOffset = CGPoint.zero
    @State var dotPosition = CGPoint.zero

    // Dot position relative to Text.
    @State var viewSize = CGSize.zero
    @State var controlPoint = CGPoint.zero

    @Namespace var namespace

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                // Button.
                Text("Button")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
                    .background(.blue.opacity(0.6))
                    .cornerRadius(20)
                    .padding(5)
                    .background(.blue.opacity(0.1))
                    .background {
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ViewSize.self, value: geometry.size)
                        }
                        .onPreferenceChange(ViewSize.self) { viewSize = $0 }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(.white.opacity(0.01))
                    .drawingGroup()

                    // Distorsion.
                    .distortionEffect(
                        ShaderLibrary.squish(
                            .float2(controlPoint)
                        ),
                        maxSampleOffset: .zero
                    )

                    // Button dot.
                    .overlay {
                        Circle()
                            .stroke(.green)
                            .fill(.green.opacity(0.2))
                            .frame(width: 10, height: 10)
                            .blendMode(.multiply)
                    }

                // Button border.
                Rectangle()
                    .stroke(.green.opacity(0.5))
                    .frame(width: viewSize.width, height: viewSize.height)
                    .blendMode(.multiply)

                // Button border.
                Rectangle()
                    .stroke(.blue.opacity(0.5))
                    .frame(width: viewSize.width, height: viewSize.height)
                    .blendMode(.multiply)
                    .position(dotPosition)

                // Dot.
                Circle()
                    .stroke(.blue.opacity(0.5), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5]))
                    .fill(.blue.opacity(0.02))
                    .frame(width: 250, height: 250)
                    .background {
                        Circle()
                            .fill(.blue.opacity(0.8))
                            .frame(width: 5, height: 5)
                    }
                    .blendMode(.multiply)
                    .position(dotPosition)


                    // Drag.
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0.0)
                            .onChanged { gesture in

                                // Update.
                                if isDragging {
                                    dotPosition = dotDragStartPosition + dotDragOffset + gesture.translation
                                    controlPoint = dotPosition - geometry.center

                                // Start.
                                } else {
                                    dotDragStartPosition = gesture.location
                                    dotDragOffset = dotPosition - gesture.location
                                    isDragging = true
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )

                    // Start centered.
                    .onAppear {
                        dotPosition = geometry.center
                    }
            }
        }
    }
}

extension GeometryProxy {

    var center: CGPoint {
        .init(x: size.width / 2, y: size.height / 2)
    }
}

extension CGPoint {

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        .init(x: left.x + right.x, y: left.y + right.y)
    }

    static func + (left: CGPoint, right: CGSize) -> CGPoint {
        .init(x: left.x + right.width, y: left.y + right.height)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        .init(x: left.x - right.x, y: left.y - right.y)
    }
}

struct ViewSize: PreferenceKey {

    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

#Preview {
    ContentView()
}
