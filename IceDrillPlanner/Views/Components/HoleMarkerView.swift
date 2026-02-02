import SwiftUI

struct HoleMarkerView: View {
    let hole: Hole
    let scale: Double
    let isSelected: Bool
    let isDragging: Bool
    
    var body: some View {
        GeometryReader { geo in
            let x = CGFloat(hole.x * scale) + geo.size.width / 2 - CGFloat(hole.x * scale) + CGFloat(hole.x * scale)
            let y = CGFloat(hole.y * scale) + geo.size.height / 2 - CGFloat(hole.y * scale) + CGFloat(hole.y * scale)
            
            ZStack {
                // Outer glow when selected or dragging
                if isSelected || isDragging {
                    Circle()
                        .fill(hole.status.color.opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                
                // Main circle
                Circle()
                    .fill(hole.status.color)
                    .frame(width: isDragging ? 32 : 28, height: isDragging ? 32 : 28)
                    .shadow(color: hole.status.color.opacity(0.5), radius: isDragging ? 8 : 4)
                
                // Number
                Text("\(hole.number)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                
                // Catch indicator
                if hole.catches > 0 {
                    Circle()
                        .fill(AppTheme.holeCaught)
                        .frame(width: 14, height: 14)
                        .overlay {
                            Text("\(hole.catches)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 12, y: -12)
                }
            }
            .position(
                x: geo.size.width / 2 - (CGFloat((geo.size.width / 2) / scale) - CGFloat(hole.x)) * scale,
                y: geo.size.height / 2 - (CGFloat((geo.size.height / 2) / scale) - CGFloat(hole.y)) * scale
            )
            .animation(.easeOut(duration: 0.15), value: isDragging)
        }
    }
}

#Preview {
    ZStack {
        AppTheme.background
        HoleMarkerView(
            hole: Hole(number: 5, x: 100, y: 100, status: .drilled, catches: 2),
            scale: 5,
            isSelected: true,
            isDragging: false
        )
    }
}
