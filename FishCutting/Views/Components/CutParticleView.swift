//
//  CutParticleView.swift
//  FishCutting
//
//  Created by William Kesuma on 17/07/25.
//

import SwiftUI

struct CutParticleView: View {
    var position: CGPoint
    var color: Color = Color(hue: 0.16, saturation: 1.0, brightness: 1.0)
    var lifetime: Double = 0.3

    @State private var particles: [TriangleParticle] = []

    struct TriangleParticle: Identifiable {
        let id = UUID()
        let angle: Double
        let offset: CGFloat
        let rotation: Double
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Triangle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(
                        x: position.x + cos(particle.angle) * particle.offset,
                        y: position.y + sin(particle.angle) * particle.offset
                    )
                    .opacity(1)
            }
        }
        .onAppear {
            generateParticles()
            DispatchQueue.main.asyncAfter(deadline: .now() + lifetime) {
                particles.removeAll()
            }
        }
    }

    private func generateParticles() {
        let spread: Double = .pi / 6      // Fan out
        let baseAngle: Double = -.pi / 2  // Launch upward

        particles = [
            TriangleParticle(angle: baseAngle - spread, offset: 38, rotation: 130),
            TriangleParticle(angle: baseAngle, offset: 50, rotation: 180),
            TriangleParticle(angle: baseAngle + spread, offset: 38, rotation: 230)
        ]
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    CutParticleView(position: CGPoint(x: 200, y: 400))
        .background(Color.black)
}
