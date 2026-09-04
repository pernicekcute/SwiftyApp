import SwiftUI

struct ContentView: View {
    // 1. Core state values
    @State private var value: Double = 0
    @State private var tempValue: Double = 0
    @State private var dragOffset: CGFloat = 0
    
    // Konfigurace haptiky
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // Tady můžeš jednoduše změnit maximální počet minut 🚀
    let maxMinutes: Double = 60
    let stepWidth: CGFloat = 20
    
    var body: some View {
        let range: ClosedRange<Double> = 0...maxMinutes
        
        VStack(spacing: 40) {
            // Selected value display label with smooth transition
            Text("\(Int(tempValue)) min")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.snappy, value: tempValue)
            
            // Slider component using GeometryReader
            GeometryReader { geometry in
                let center = geometry.size.width / 2
                
                // KLÍČOVÁ OPRAVA: alignment: .leading zajistí správný počátek osy zleva
                ZStack(alignment: .leading) {
                    HStack(spacing: stepWidth) {
                        ForEach(Int(range.lowerBound)...Int(range.upperBound), id: \.self) { tick in
                            VStack(spacing: 6) {
                                // Zaoblený indikátor
                                Capsule()
                                    .fill(tick == Int(tempValue) ? Color.white : Color.gray.opacity(0.5))
                                    .frame(width: tick == Int(tempValue) ? 3 : 2,
                                           height: tick % 5 == 0 ? 30 : 15)
                                
                                // Čísla pod ryskami
                                if tick % 5 == 0 {
                                    Text("\(tick)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .fixedSize()
                                } else {
                                    Text("")
                                        .font(.caption2)
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    // Přesný posun tak, aby vybraná hodnota byla přesně uprostřed
                    .offset(x: center - (CGFloat(value) * stepWidth) + dragOffset)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let rawOffset = gesture.translation.width
                            
                            // Logarithmic resistance curve for elasticity at limits
                            let projected = value - Double(rawOffset / stepWidth)
                            if projected < range.lowerBound {
                                let excess = range.lowerBound - projected
                                dragOffset = rawOffset + CGFloat(log(excess + 1) * 15)
                            } else if projected > range.upperBound {
                                let excess = projected - range.upperBound
                                dragOffset = rawOffset - CGFloat(log(excess + 1) * 15)
                            } else {
                                dragOffset = rawOffset
                            }
                            
                            tempValue = projected.clamped(to: range).rounded()
                        }
                        .onEnded { _ in
                            withAnimation(.snappy) {
                                let finalProjected = value - Double(dragOffset / stepWidth)
                                value = finalProjected.clamped(to: range).rounded()
                                tempValue = value
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(height: 120)
        }
        .preferredColorScheme(.dark)
        .padding()
        .onAppear {
            feedbackGenerator.prepare()
            tempValue = value
        }
        .onChange(of: Int(tempValue)) { oldValue, newValue in
            if oldValue != newValue {
                feedbackGenerator.impactOccurred()
                feedbackGenerator.prepare()
            }
        }
    }
}

// Helper extension for clamping values safely
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    ContentView()
}
