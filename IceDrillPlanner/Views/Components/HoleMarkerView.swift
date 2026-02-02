import SwiftUI

struct HoleMarkerView: View {
    let hole: Hole
    let scale: Double
    let zoneWidth: Double
    let zoneHeight: Double
    let isSelected: Bool
    let isDragging: Bool
    
    var body: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            
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
                x: centerX + CGFloat((hole.x - zoneWidth / 2) * scale),
                y: centerY + CGFloat((hole.y - zoneHeight / 2) * scale)
            )
            .animation(.easeOut(duration: 0.15), value: isDragging)
        }
    }
}

#Preview {
    ZStack {
        AppTheme.background
        HoleMarkerView(
            hole: Hole(number: 5, x: 25, y: 15, status: .drilled, catches: 2),
            scale: 5,
            zoneWidth: 50,
            zoneHeight: 30,
            isSelected: true,
            isDragging: false
        )
    }
}
