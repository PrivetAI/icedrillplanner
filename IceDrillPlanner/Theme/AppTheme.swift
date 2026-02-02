import SwiftUI

struct AppTheme {
    // MARK: - Background Colors
    static let background = Color(hex: "0A1628")
    static let cardBackground = Color(hex: "132744")
    static let cardBackgroundLight = Color(hex: "1A3556")
    static let surface = Color(hex: "1E3A5F")
    
    // MARK: - Primary Colors
    static let primary = Color(hex: "4FC3F7")
    static let accent = Color(hex: "81D4FA")
    static let accentLight = Color(hex: "B3E5FC")
    
    // MARK: - Hole Status Colors
    static let holePlanned = Color(hex: "42A5F5")      // Blue - planned
    static let holeDrilled = Color(hex: "66BB6A")      // Green - drilled
    static let holeActive = Color(hex: "FFCA28")       // Yellow - active fishing
    static let holeCaught = Color(hex: "EF5350")       // Red - caught fish
    static let holeEmpty = Color(hex: "78909C")        // Gray - empty
    
    // MARK: - Status Colors
    static let danger = Color(hex: "EF5350")
    static let warning = Color(hex: "FFB74D")
    static let success = Color(hex: "66BB6A")
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "B0BEC5")
    static let textMuted = Color(hex: "78909C")
    
    // MARK: - Ice/Water Colors
    static let iceLight = Color(hex: "E3F2FD")
    static let iceMedium = Color(hex: "90CAF9")
    static let waterDeep = Color(hex: "1565C0")
    
    // MARK: - Gradients
    static let iceGradient = LinearGradient(
        colors: [Color(hex: "4FC3F7"), Color(hex: "0288D1")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let frostGradient = LinearGradient(
        colors: [Color(hex: "E3F2FD"), Color(hex: "90CAF9")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let nightGradient = LinearGradient(
        colors: [Color(hex: "0A1628"), Color(hex: "1A3556")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32
    
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 20
    static let cornerRadiusXLarge: CGFloat = 28
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
