//
//  StreamShape.swift
//  Chimpions
//
//  Created by Nunzio Ricci on 22/02/23.
//

import SwiftUI

struct StreamShape: Shape {
    var animationStatus: Double = 0
    
    let precision: Double = 100
    
    var animatableData: Double {
        get { animationStatus }
        set { animationStatus = newValue }
    }
    
    func offset(for position: Double) -> CGVector {
        let x = 2 * .pi * (animationStatus + position)
        let y = 2 * .pi * (2 * animationStatus + position)
        return 10 * CGVector(dx: 0, dy: (sin(x) + cos(2*y))/2)
    }
    
    func restPoint(for position: Double, in rect: CGRect, bottom: Bool = false) -> CGPoint {
        CGPoint(x: rect.origin.x + rect.width * position,
                y: rect.origin.y + (bottom ? rect.height : 0))
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startingPoint = rect.origin + offset(for: 0)
        path.move(to: startingPoint)
        for position in stride(from: 1/precision, to: 1+1/precision, by: 1 / precision) {
            let controlPosition = position - 0.5 / precision
            let controlPoint = restPoint(for: controlPosition, in: rect) + offset(for: controlPosition)
            let point = restPoint(for: position, in: rect) + offset(for: controlPosition)
            path.addQuadCurve(to: point, control: controlPoint)
        }
        path.addLine(to: startingPoint + CGVector(dx: rect.width, dy: rect.height))
        for position in stride(from: 1, to: -1/precision, by: -1 / precision) {
            let controlPosition = position + 0.5 / precision
            let controlPoint = restPoint(for: controlPosition, in: rect, bottom: true) + offset(for: controlPosition)
            let point = restPoint(for: position, in: rect, bottom: true) + offset(for: controlPosition)
            path.addQuadCurve(to: point, control: controlPoint)
        }
        
        return path
    }
}

struct StreamComponent: View {
    @State var animationStatus = 0.0
    
    var body: some View {
        StreamShape(animationStatus: animationStatus)
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    animationStatus += 1
                }
            }
    }
}

struct StreamShape_Previews: PreviewProvider {
    static var previews: some View {
        StreamComponent()
    }
}
