//
//  StackSprintView.swift
//  StackSprint
//
//  Created by Jarvis on 2025-06-21.
//

import SwiftUI
import CoreHaptics
import AVFoundation

struct FeatureCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var isAccepted: Bool? = nil
}

struct StackSprintView: View {
    @State private var cards = [
        FeatureCard(title: "Dark Mode", description: "Let users switch themes"),
        FeatureCard(title: "Offline Sync", description: "Allow work without internet"),
        FeatureCard(title: "AI Summary", description: "Summarize meeting notes automatically"),
        FeatureCard(title: "Live Chat", description: "Add customer chat in-app")
    ]

    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var engine: CHHapticEngine?
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 16) {
            Text("StackSprint")
                .font(.largeTitle.bold())
                .padding(.top)

            if currentIndex < cards.count {
                ZStack {
                    ForEach(Array((0..<cards.count).reversed()), id: \.self) { index in
                        if index >= currentIndex {
                            SprintCardView(
                                card: cards[index],
                                dragOffset: index == currentIndex ? dragOffset : .zero
                            )
                            .offset(x: index == currentIndex ? dragOffset.width : 0,
                                    y: index == currentIndex ? dragOffset.height : CGFloat(index - currentIndex) * 10)
                            .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                            .scaleEffect(index == currentIndex ? 1.0 : 0.95)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        dragOffset = gesture.translation
                                    }
                                    .onEnded { value in
                                        if abs(value.translation.width) > 100 {
                                            triggerHaptic()
                                            playSound(named: value.translation.width > 0 ? "success" : "fail")
                                            withAnimation(.spring()) {
                                                handleSwipe(direction: value.translation.width > 0)
                                                dragOffset = .zero
                                            }
                                        } else {
                                            dragOffset = .zero
                                        }
                                    }
                            )
                        }
                    }
                }
                .frame(height: 320)

                Text("Card \(currentIndex + 1) of \(cards.count)")
                    .foregroundColor(.gray)

                Button("Reset") {
                    currentIndex = 0
                    cards = cards.map { FeatureCard(title: $0.title, description: $0.description) }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("All features sorted!")
                        .font(.title2)
                    Button("Start Again") {
                        withAnimation {
                            currentIndex = 0
                            cards = cards.map { FeatureCard(title: $0.title, description: $0.description) }
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .onAppear {
            prepareHaptics()
        }
    }

    private func handleSwipe(direction: Bool) {
        cards[currentIndex].isAccepted = direction
        currentIndex += 1
    }

    private func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics error: \(error.localizedDescription)")
        }
    }

    private func triggerHaptic() {
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)

        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }

    private func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound file not found: \(name).mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Audio error: \(error.localizedDescription)")
        }
    }
}

struct SprintCardView: View {
    let card: FeatureCard
    var dragOffset: CGSize

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8)

            VStack(spacing: 12) {
                Text(card.title)
                    .font(.title2.bold())
                Text(card.description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding()

            HStack {
                if dragOffset.width > 0 {
                    Text("✅ Yes")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                        .opacity(Double(min(dragOffset.width / 100, 1)))
                        .rotationEffect(.degrees(-15))
                        .offset(x: -60, y: -80)
                } else if dragOffset.width < 0 {
                    Text("❌ No")
                        .font(.title2.bold())
                        .foregroundColor(.red)
                        .opacity(Double(min(abs(dragOffset.width) / 100, 1)))
                        .rotationEffect(.degrees(15))
                        .offset(x: 60, y: -80)
                }
            }
        }
        .frame(height: 240)
        .padding(.horizontal)
    }
}

#Preview {
    StackSprintView()
}
