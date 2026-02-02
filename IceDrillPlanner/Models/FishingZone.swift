import Foundation

// MARK: - Zone Shape
enum ZoneShape: String, Codable, CaseIterable, Identifiable {
    case rectangle = "rectangle"
    case circle = "circle"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .rectangle: return "Прямоугольник"
        case .circle: return "Круг"
        }
    }
    
    var icon: String {
        switch self {
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        }
    }
}

// MARK: - Fishing Zone
struct FishingZone: Codable, Equatable {
    var shape: ZoneShape
    var width: Double  // meters
    var height: Double // meters (for rectangle) or radius (for circle)
    var depth: Double  // water depth in meters
    var iceThickness: Double // cm
    
    init(
        shape: ZoneShape = .rectangle,
        width: Double = 50,
        height: Double = 30,
        depth: Double = 5,
        iceThickness: Double = 30
    ) {
        self.shape = shape
        self.width = width
        self.height = height
        self.depth = depth
        self.iceThickness = iceThickness
    }
    
    var area: Double {
        switch shape {
        case .rectangle:
            return width * height
        case .circle:
            return Double.pi * height * height // height is radius
        }
    }
    
    var displaySize: String {
        switch shape {
        case .rectangle:
            return "\(Int(width))м × \(Int(height))м"
        case .circle:
            return "R = \(Int(height))м"
        }
    }
}
