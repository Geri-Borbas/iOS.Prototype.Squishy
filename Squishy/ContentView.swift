//
//  ContentView.swift
//  Squishy
//
//  Created by Geri on 11/05/2024.
//

import SwiftUI

struct ContentView: View {

    @State var position = CGPoint.zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                // MARK: View

                Grid(
                    rows: Metrics.rows,
                    columns: Metrics.columns,
                    color: .green.opacity(0.6)
                )
                .frame(size: Metrics.size)
                .background(.green.opacity(0.2))
                .frame(size: Metrics.Layer.size)
                .background {
                    Grid(
                        rows: Metrics.Layer.rows,
                        columns: Metrics.Layer.columns,
                        color: .green.opacity(0.2)
                    )
                }
                .drawingGroup()

                // Distorsion.
                .squish(
                    layerCenter: Metrics.Layer.size.center,
                    anchorPoint: Metrics.Layer.size.center,
                    controlPoint: position - geometry.center
                )


                // Layer border.
                .border(.green.opacity(0.2))

                // MARK: Debug

                // View.
                Rectangle()
                    .stroke(.gray.opacity(0.5))
                    .background {
                        Grid(
                            rows: Metrics.rows,
                            columns: Metrics.columns,
                            color: .gray.opacity(0.2)
                        )
                    }
                    .overlay {
                        Circle()
                            .stroke(.gray)
                            .frame(width: 10, height: 10)
                            .blendMode(.multiply)
                    }
                    .frame(size: Metrics.size)
                    .blendMode(.multiply)

                // Target view.
                Rectangle()
                    .stroke(.blue.opacity(0.5))
                    .frame(size: Metrics.size)
                    .position(position)
                    .blendMode(.multiply)

                // MARK: Dot

                // Dot.
                DragPoint(
                    position: $position,
                    onEnded: {
                        // Reset to center when drag ended.
                        withAnimation(Animation.spring) {
                            position = geometry.center
                        }
                    }
                )
                .blendMode(.multiply)
            }

            // Start centered.
            .onAppear {
                position = geometry.center
            }
        }
    }
}

// MARK: - Squish

struct AnimatableDistortionModifier: ViewModifier, Animatable {

    var layerCenter: CGPoint
    var anchorPoint: CGPoint
    var controlPoint: CGPoint

    var animatableData: CGPoint.AnimatableData {
        get { controlPoint.animatableData }
        set { controlPoint.animatableData = newValue }
    }

    func body(content: Content) -> some View {
        content
            .distortionEffect(
                ShaderLibrary.squish(
                    .float2(layerCenter),
                    .float2(anchorPoint),
                    .float2(controlPoint)
                ),
                maxSampleOffset: .zero
            )
    }
}

extension View {

    func squish(layerCenter: CGPoint, anchorPoint: CGPoint, controlPoint: CGPoint) -> some View {
        self.modifier(
            AnimatableDistortionModifier(
                layerCenter: layerCenter,
                anchorPoint: anchorPoint,
                controlPoint: controlPoint
            )
        )
    }
}

// MARK: - Views

struct DragPoint: View {

    @Binding var position: CGPoint
    let onEnded: () -> Void

    @State private var isDragging = false
    @State private var dragStartPosition = CGPoint.zero
    @State private var dragOffset = CGPoint.zero

    var body: some View {
        Circle()
            .stroke(.blue.opacity(0.5), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5]))
            .fill(.blue.opacity(0.02))
            .frame(width: 360, height: 360)
            .background {
                Circle()
                    .fill(.blue.opacity(0.8))
                    .frame(width: 5, height: 5)
            }
            .position(position)

            // Drag.
            .simultaneousGesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { gesture in

                        // Update.
                        if isDragging {
                            position = dragStartPosition + dragOffset + gesture.translation

                        // Start.
                        } else {
                            dragStartPosition = gesture.location
                            dragOffset = position - gesture.location
                            isDragging = true
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEnded()
                    }
            )
    }
}

struct Grid: View {

    var rows: Int
    var columns: Int
    var color: Color

    var body: some View {
        ZStack {
            HStack {
                ForEach(0 ..< columns, id: \.self) { _ in
                    Rectangle().fill(color).frame(width: 1)
                    Spacer()
                }
                Rectangle().fill(color).frame(width: 1)
            }
            VStack {
                ForEach(0 ..< rows, id: \.self) { _ in
                    Rectangle().fill(color).frame(height: 1)
                    Spacer()
                }
                Rectangle().fill(color).frame(height: 1)
            }
        }
    }
}

// MARK: - Metrics

extension ContentView {

    struct Metrics {

        static let rows = 8
        static let columns = 12
        static let gridSize = CGSize(width: 20, height: 20)

        struct Layer {

            static let rows = 24
            static let columns = 18

            static let size = CGSize(
                width: CGFloat(columns) * Metrics.gridSize.width,
                height: CGFloat(rows) * Metrics.gridSize.height
            )
        }

        static let size = CGSize(
            width: CGFloat(columns) * gridSize.width,
            height: CGFloat(rows) * gridSize.height
        )
    }
}

// MARK: - Extensions

extension GeometryProxy {

    var center: CGPoint {
        size.center
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

extension CGSize {

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        .init(width: left.width / right, height: left.height / right)
    }

    var center: CGPoint {
        .init(x: width / 2, y: height / 2)
    }
}

struct ViewSize: PreferenceKey {

    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    @inlinable public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}

struct Animation {

    static let spring = SwiftUI.Animation.spring(
        response: 0.36,
        dampingFraction: 0.24,
        blendDuration: 0.0
    )
}

// MARK: - Preview

#Preview {
    ContentView()
}
