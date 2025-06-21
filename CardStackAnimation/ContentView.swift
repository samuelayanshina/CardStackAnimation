//
//  ContentView.swift
//  CardStackAnimation
//
//  Created by USER on 6/21/25.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let color: Color
    let title: String
}

struct ContentView: View {
    let cards: [Card] = [
        Card(color: .blue, title: "Fix onboarding drop-off"),
        Card(color: .purple, title: "Integrate Stripe billing"),
        Card(color: .green, title: "Ship Android beta"),
        Card(color: .orange, title: "Improve dashboard load time")
    ]
    
    @State private var topIndex: Int = 0

    var body: some View {
        ZStack {
            ForEach(cards.indices.reversed(), id: \.self) { index in
                CardView(card: cards[index])
                    .offset(y: CGFloat(index - topIndex) * 15)
                    .scaleEffect(index == topIndex ? 1 : 0.95)
                    .opacity(index >= topIndex ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: topIndex)
                    .onTapGesture {
                        if topIndex < cards.count - 1 {
                            topIndex += 1
                        } else {
                            topIndex = 0
                        }
                    }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct CardView: View {
    let card: Card

    var body: some View {
        VStack(spacing: 12) {
            Text(card.title)
                .font(.title2.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(card.color)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    ContentView()
}
