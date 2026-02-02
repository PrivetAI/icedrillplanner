import Foundation
import SwiftUI

// MARK: - Hole Status
enum HoleStatus: String, Codable, CaseIterable, Identifiable {
    case planned = "planned"
    case drilled = "drilled"
    case active = "active"
    case caught = "caught"
    case empty = "empty"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .planned: return "Запланирована"
        case .drilled: return "Пробурена"
        case .active: return "Активная"
        case .caught: return "Поклёвка!"
        case .empty: return "Пустая"
        }
    }
    
    var color: Color {
        switch self {
        case .planned: return AppTheme.holePlanned
        case .drilled: return AppTheme.holeDrilled
        case .active: return AppTheme.holeActive
        case .caught: return AppTheme.holeCaught
        case .empty: return AppTheme.holeEmpty
        }
    }
    
    var icon: String {
        switch self {
        case .planned: return "circle.dotted"
        case .drilled: return "checkmark.circle"
        case .active: return "flag.fill"
        case .caught: return "fish.fill"
        case .empty: return "xmark.circle"
        }
    }
}

// MARK: - Hole
struct Hole: Codable, Identifiable, Equatable {
    let id: UUID
    var number: Int
    var x: Double // position in meters from origin
    var y: Double
    var status: HoleStatus
    var depth: Double? // actual water depth at this hole
    var notes: String
    var catches: Int
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        number: Int,
        x: Double,
        y: Double,
        status: HoleStatus = .planned,
        depth: Double? = nil,
        notes: String = "",
        catches: Int = 0
    ) {
        self.id = id
        self.number = number
        self.x = x
        self.y = y
        self.status = status
        self.depth = depth
        self.notes = notes
        self.catches = catches
        self.createdAt = Date()
    }
    
    var position: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    func distance(to other: Hole) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
}
