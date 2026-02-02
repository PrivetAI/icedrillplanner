import Foundation

// MARK: - Fish Type
enum FishType: String, Codable, CaseIterable, Identifiable {
    case perch = "perch"
    case pike = "pike"
    case zander = "zander"
    case trout = "trout"
    case roach = "roach"
    case burbot = "burbot"
    case mixed = "mixed"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .perch: return "Окунь"
        case .pike: return "Щука"
        case .zander: return "Судак"
        case .trout: return "Форель"
        case .roach: return "Плотва"
        case .burbot: return "Налим"
        case .mixed: return "Смешанная"
        }
    }
    
    var emoji: String {
        switch self {
        case .perch: return "🐟"
        case .pike: return "🐊"
        case .zander: return "🐠"
        case .trout: return "🐡"
        case .roach: return "🐟"
        case .burbot: return "🐍"
        case .mixed: return "🎣"
        }
    }
    
    var recommendedSpacing: Double {
        switch self {
        case .perch: return 5.0  // groups, close
        case .pike: return 12.0 // loner, far apart
        case .zander: return 8.0
        case .trout: return 7.0
        case .roach: return 6.0 // schools
        case .burbot: return 10.0
        case .mixed: return 7.0
        }
    }
    
    var recommendedPattern: HolePattern {
        switch self {
        case .perch: return .grid
        case .pike: return .random
        case .zander: return .line
        case .trout: return .zigzag
        case .roach: return .grid
        case .burbot: return .line
        case .mixed: return .zigzag
        }
    }
    
    var description: String {
        switch self {
        case .perch: return "Стайная рыба, мелководье. Лунки близко, сеткой."
        case .pike: return "Одиночный хищник. Лунки далеко, у травы и коряг."
        case .zander: return "Глубина, перепады. Линия вдоль свала."
        case .trout: return "Глубина, кислород. Холодные зоны."
        case .roach: return "Большие стаи, средняя глубина."
        case .burbot: return "Ночная рыба, глубокие ямы."
        case .mixed: return "Универсальный подход для разной рыбы."
        }
    }
}

// MARK: - Fishing Plan
struct FishingPlan: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var zone: FishingZone
    var holes: [Hole]
    var pattern: HolePattern
    var targetFish: FishType
    var spacing: Double
    var createdAt: Date
    var updatedAt: Date
    var notes: String
    
    init(
        id: UUID = UUID(),
        name: String = "Новый план",
        zone: FishingZone = FishingZone(),
        holes: [Hole] = [],
        pattern: HolePattern = .grid,
        targetFish: FishType = .perch,
        spacing: Double = 5.0,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.zone = zone
        self.holes = holes
        self.pattern = pattern
        self.targetFish = targetFish
        self.spacing = spacing
        self.createdAt = Date()
        self.updatedAt = Date()
        self.notes = notes
    }
    
    // MARK: - Statistics
    var totalHoles: Int { holes.count }
    
    var drilledHoles: Int {
        holes.filter { $0.status != .planned }.count
    }
    
    var activeHoles: Int {
        holes.filter { $0.status == .active }.count
    }
    
    var holesWithCatches: Int {
        holes.filter { $0.status == .caught || $0.catches > 0 }.count
    }
    
    var totalCatches: Int {
        holes.reduce(0) { $0 + $1.catches }
    }
    
    var averageDistance: Double {
        guard holes.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        var count = 0
        
        for i in 0..<holes.count {
            for j in (i + 1)..<holes.count {
                totalDistance += holes[i].distance(to: holes[j])
                count += 1
            }
        }
        
        return count > 0 ? totalDistance / Double(count) : 0
    }
    
    var minDistance: Double {
        guard holes.count > 1 else { return 0 }
        
        var minDist = Double.infinity
        
        for i in 0..<holes.count {
            for j in (i + 1)..<holes.count {
                let d = holes[i].distance(to: holes[j])
                if d < minDist {
                    minDist = d
                }
            }
        }
        
        return minDist == .infinity ? 0 : minDist
    }
    
    var maxDistance: Double {
        guard holes.count > 1 else { return 0 }
        
        var maxDist: Double = 0
        
        for i in 0..<holes.count {
            for j in (i + 1)..<holes.count {
                let d = holes[i].distance(to: holes[j])
                if d > maxDist {
                    maxDist = d
                }
            }
        }
        
        return maxDist
    }
    
    var coveragePercent: Double {
        guard zone.area > 0 && holes.count > 0 else { return 0 }
        // Approximate: each hole covers circle of radius = spacing/2
        let holeArea = Double.pi * (spacing / 2) * (spacing / 2)
        let covered = Double(holes.count) * holeArea
        return min(100, (covered / zone.area) * 100)
    }
    
    // MARK: - Mutating
    mutating func updateHole(id: UUID, with update: (inout Hole) -> Void) {
        if let index = holes.firstIndex(where: { $0.id == id }) {
            update(&holes[index])
            updatedAt = Date()
        }
    }
    
    mutating func regenerateHoles() {
        holes = PatternGenerator.generateHoles(
            pattern: pattern,
            zone: zone,
            count: 20, // default
            spacing: spacing
        )
        updatedAt = Date()
    }
}
