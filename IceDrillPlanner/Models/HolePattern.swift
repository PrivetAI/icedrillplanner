import Foundation

// MARK: - Hole Pattern
enum HolePattern: String, Codable, CaseIterable, Identifiable {
    case grid = "grid"
    case line = "line"
    case zigzag = "zigzag"
    case circle = "circle"
    case fan = "fan"
    case random = "random"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .grid: return "Сетка"
        case .line: return "Линия"
        case .zigzag: return "Зигзаг"
        case .circle: return "Круг"
        case .fan: return "Веер"
        case .random: return "Случайный"
        }
    }
    
    var description: String {
        switch self {
        case .grid: return "Равномерная сетка для максимального покрытия"
        case .line: return "Одна линия вдоль глубины или берега"
        case .zigzag: return "Зигзагообразное расположение"
        case .circle: return "Лунки по кругу вокруг центра"
        case .fan: return "Веером от берега вглубь"
        case .random: return "Случайное расположение"
        }
    }
    
    var icon: String {
        switch self {
        case .grid: return "square.grid.3x3"
        case .line: return "line.horizontal.3"
        case .zigzag: return "point.topleft.down.to.point.bottomright.curvepath"
        case .circle: return "circle.dashed"
        case .fan: return "wind"
        case .random: return "dice"
        }
    }
    
    // ASCII preview for pattern selection
    var preview: String {
        switch self {
        case .grid:
            return """
            ○ ○ ○ ○
            ○ ○ ○ ○
            ○ ○ ○ ○
            """
        case .line:
            return """
            ○─○─○─○─○─○
            """
        case .zigzag:
            return """
            ○   ○   ○
              ○   ○   ○
            """
        case .circle:
            return """
              ○   ○
            ○   ✕   ○
              ○   ○
            """
        case .fan:
            return """
                ○ ○ ○
              ○ ○ ○
            ✕
            """
        case .random:
            return """
              ○     ○
                ○       ○
             ○       ○
            """
        }
    }
}

// MARK: - Pattern Generator
struct PatternGenerator {
    
    static func generateHoles(
        pattern: HolePattern,
        zone: FishingZone,
        count: Int,
        spacing: Double
    ) -> [Hole] {
        switch pattern {
        case .grid:
            return generateGrid(zone: zone, spacing: spacing)
        case .line:
            return generateLine(zone: zone, count: count, spacing: spacing)
        case .zigzag:
            return generateZigzag(zone: zone, count: count, spacing: spacing)
        case .circle:
            return generateCircle(zone: zone, count: count)
        case .fan:
            return generateFan(zone: zone, count: count, spacing: spacing)
        case .random:
            return generateRandom(zone: zone, count: count, minSpacing: spacing)
        }
    }
    
    // MARK: - Grid Pattern
    private static func generateGrid(zone: FishingZone, spacing: Double) -> [Hole] {
        var holes: [Hole] = []
        var number = 1
        
        let (maxX, maxY) = zoneMaxDimensions(zone)
        let padding = spacing / 2
        
        var y = padding
        while y < maxY - padding {
            var x = padding
            while x < maxX - padding {
                if isInsideZone(x: x, y: y, zone: zone) {
                    holes.append(Hole(number: number, x: x, y: y))
                    number += 1
                }
                x += spacing
            }
            y += spacing
        }
        
        return holes
    }
    
    // MARK: - Line Pattern
    private static func generateLine(zone: FishingZone, count: Int, spacing: Double) -> [Hole] {
        var holes: [Hole] = []
        
        let (maxX, maxY) = zoneMaxDimensions(zone)
        let centerY = maxY / 2
        let totalLength = Double(count - 1) * spacing
        let startX = max((maxX - totalLength) / 2, spacing / 2)
        
        for i in 0..<count {
            let x = startX + Double(i) * spacing
            if x < maxX - spacing / 2 {
                holes.append(Hole(number: i + 1, x: x, y: centerY))
            }
        }
        
        return holes
    }
    
    // MARK: - Zigzag Pattern
    private static func generateZigzag(zone: FishingZone, count: Int, spacing: Double) -> [Hole] {
        var holes: [Hole] = []
        
        let (maxX, maxY) = zoneMaxDimensions(zone)
        let rowSpacing = spacing * 0.866 // sqrt(3)/2 for equilateral offset
        let padding = spacing / 2
        
        var number = 1
        var row = 0
        var y = padding
        
        while y < maxY - padding && number <= count {
            let offset = (row % 2 == 0) ? 0 : spacing / 2
            var x = padding + offset
            
            while x < maxX - padding && number <= count {
                if isInsideZone(x: x, y: y, zone: zone) {
                    holes.append(Hole(number: number, x: x, y: y))
                    number += 1
                }
                x += spacing
            }
            y += rowSpacing
            row += 1
        }
        
        return holes
    }
    
    // MARK: - Circle Pattern
    private static func generateCircle(zone: FishingZone, count: Int) -> [Hole] {
        var holes: [Hole] = []
        
        let (maxX, maxY) = zoneMaxDimensions(zone)
        let centerX = maxX / 2
        let centerY = maxY / 2
        let radius = min(maxX, maxY) / 2 - 3 // 3m padding
        
        for i in 0..<count {
            let angle = (2 * Double.pi / Double(count)) * Double(i) - Double.pi / 2
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            holes.append(Hole(number: i + 1, x: x, y: y))
        }
        
        return holes
    }
    
    // MARK: - Fan Pattern
    private static func generateFan(zone: FishingZone, count: Int, spacing: Double) -> [Hole] {
        var holes: [Hole] = []
        
        let (maxX, maxY) = zoneMaxDimensions(zone)
        let originX = maxX / 2
        let originY = 2.0 // near the bottom edge
        
        let maxRadius = min(maxX / 2, maxY) - 3
        let rings = max(2, Int(maxRadius / spacing))
        let angleSpread = Double.pi * 0.6 // 108 degrees
        
        var number = 1
        for ring in 1...rings {
            let radius = Double(ring) * spacing
            let holesInRing = min(count - holes.count, ring + 2)
            
            if holesInRing <= 0 { break }
            
            for i in 0..<holesInRing {
                let t = Double(i) / Double(max(1, holesInRing - 1))
                let angle = -Double.pi / 2 - angleSpread / 2 + t * angleSpread
                let x = originX + radius * cos(angle)
                let y = originY - radius * sin(angle)
                
                if isInsideZone(x: x, y: y, zone: zone) && number <= count {
                    holes.append(Hole(number: number, x: x, y: y))
                    number += 1
                }
            }
        }
        
        return holes
    }
    
    // MARK: - Random Pattern
    private static func generateRandom(zone: FishingZone, count: Int, minSpacing: Double) -> [Hole] {
        var holes: [Hole] = []
        var attempts = 0
        let maxAttempts = count * 100
        
        let (maxX, maxY) = zoneMaxDimensions(zone)
        let padding = minSpacing / 2
        
        while holes.count < count && attempts < maxAttempts {
            let x = Double.random(in: padding...(maxX - padding))
            let y = Double.random(in: padding...(maxY - padding))
            
            // Check if inside zone
            guard isInsideZone(x: x, y: y, zone: zone) else {
                attempts += 1
                continue
            }
            
            // Check minimum spacing
            let tooClose = holes.contains { hole in
                let dx = hole.x - x
                let dy = hole.y - y
                return sqrt(dx * dx + dy * dy) < minSpacing
            }
            
            if !tooClose {
                holes.append(Hole(number: holes.count + 1, x: x, y: y))
            }
            
            attempts += 1
        }
        
        return holes
    }
    
    // MARK: - Helpers
    private static func zoneMaxDimensions(_ zone: FishingZone) -> (Double, Double) {
        switch zone.shape {
        case .rectangle:
            return (zone.width, zone.height)
        case .circle:
            return (zone.height * 2, zone.height * 2)
        }
    }
    
    private static func isInsideZone(x: Double, y: Double, zone: FishingZone) -> Bool {
        switch zone.shape {
        case .rectangle:
            return x >= 0 && x <= zone.width && y >= 0 && y <= zone.height
        case .circle:
            let centerX = zone.height
            let centerY = zone.height
            let dx = x - centerX
            let dy = y - centerY
            return sqrt(dx * dx + dy * dy) <= zone.height
        }
    }
}
