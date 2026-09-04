import SwiftUI
import UIKit

// MARK: - Hlavní ContentView 📱
struct ContentView: View {
    var body: some View {
        TabView {
            // 🔹 První Tab
            Tab("Tab 1", systemImage: "rhombus.fill") {
                Tab1View()
            }
            
            // 🔹 Druhý Tab
            Tab("Tab 2", systemImage: "circle.fill") {
                Tab2View()
            }
            
            // 🔹 Třetí Tab
            Tab("Tab 3", systemImage: "square.fill") {
                Tab3View()
            }
        }
    }
}

// MARK: - Stránka pro Tab 1 💎
struct Tab1View: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Default tab bar appearance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Content area")
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer() 
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading) 
            .navigationTitle("Tab 1") 
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.dashed")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

// MARK: - Stránka pro Tab 2 🔴
struct Tab2View: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Default tab bar appearance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Content area")
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer() 
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading) 
            .navigationTitle("Tab 2") 
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.dashed")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

// MARK: - Stránka pro Tab 3 ⬛️
struct Tab3View: View {
    @State private var value: Double = 0
    @State private var tempValue: Double = 0
    @State private var dragOffset: CGFloat = 0
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    let maxMinutes: Double = 60
    let stepWidth: CGFloat = 20
    
    var body: some View {
        let range: ClosedRange<Double> = 0...maxMinutes
        
        NavigationStack {
            VStack(spacing: 40) {
                Text("\(Int(tempValue)) min")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: tempValue)
                
                GeometryReader { geometry in
                    let center = geometry.size.width / 2
                    
                    ZStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            ForEach(Int(range.lowerBound)...Int(range.upperBound), id: \.self) { tick in
                                VStack(spacing: 6) {
                                    Capsule()
                                        .fill(tick == Int(tempValue) ? Color.white : Color.gray.opacity(0.5))
                                        .frame(width: tick == Int(tempValue) ? 3 : 2,
                                               height: tick % 5 == 0 ? 30 : 15)
                                    
                                    if tick % 5 == 0 {
                                        Text("\(tick)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .fixedSize()
                                    } else {
                                        Text("\(tick)") 
                                            .font(.caption2)
                                            .opacity(0)
                                    }
                                }
                                .frame(width: stepWidth)
                            }
                        }
                        .offset(x: center - (stepWidth / 2) - (CGFloat(value) * stepWidth) + dragOffset)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let rawOffset = gesture.translation.width
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
            .padding()
            .navigationTitle("Tab 3")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.dashed")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                }
            }
            .preferredColorScheme(.dark)
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
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    ContentView()
}
