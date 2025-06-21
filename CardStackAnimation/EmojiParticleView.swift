//
//  EmojiParticleView.swift
//  CardStackAnimation
//
//  Created by USER on 6/21/25.
//
import SwiftUI

struct EmojiParticleView: View {
    @State private var particles: [UUID] = []

    var emoji: String = "🎉"
    var count: Int = 20

    var body: some View {
        ZStack {
            ForEach(particles, id: \.self) { id in
                Text(emoji)
                    .font(.largeTitle)
                    .position(x: CGFloat.random(in: 50...300), y: CGFloat.random(in: 100...300))
                    .opacity(0.8)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeOut(duration: 1).delay(Double.random(in: 0...0.3)), value: particles)
            }
        }
        .onAppear {
            for _ in 0..<count {
                particles.append(UUID())
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                particles.removeAll()
            }
        }
    }
}

