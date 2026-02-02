import Foundation
import CoreGraphics

// MARK: - Geometry Utils
struct GeometryUtils {
    
    /// Calculate distance between two points in meters
    static func distance(from p1: CGPoint, to p2: CGPoint) -> Double {
        let dx = Double(p2.x - p1.x)
        let dy = Double(p2.y - p1.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Convert meters to screen points
    static func metersToPoints(_ meters: Double, scale: Double) -> CGFloat {
        CGFloat(meters * scale)
    }
    
    /// Convert screen points to meters
    static func pointsToMeters(_ points: CGFloat, scale: Double) -> Double {
        Double(points) / scale
    }
    
    /// Calculate scale to fit zone in canvas
    static func calculateScale(zoneWidth: Double, zoneHeight: Double, canvasSize: CGSize, padding: CGFloat = 40) -> Double {
        let availableWidth = Double(canvasSize.width - padding * 2)
        let availableHeight = Double(canvasSize.height - padding * 2)
        
        let scaleX = availableWidth / zoneWidth
        let scaleY = availableHeight / zoneHeight
        
        return min(scaleX, scaleY)
    }
    
    /// Calculate total path length through all holes
    static func totalPathLength(holes: [Hole]) -> Double {
        guard holes.count > 1 else { return 0 }
        
        var total: Double = 0
        for i in 0..<(holes.count - 1) {
            total += holes[i].distance(to: holes[i + 1])
        }
        return total
    }
    
    /// Find nearest neighbor path (simple TSP approximation)
    static func optimizedPath(holes: [Hole], startIndex: Int = 0) -> [Hole] {
        guard holes.count > 1 else { return holes }
        
        var remaining = holes
        var path: [Hole] = []
        
        var current = remaining.remove(at: min(startIndex, remaining.count - 1))
        path.append(current)
        
        while !remaining.isEmpty {
            var nearestIndex = 0
            var nearestDistance = Double.infinity
            
            for (index, hole) in remaining.enumerated() {
                let d = current.distance(to: hole)
                if d < nearestDistance {
                    nearestDistance = d
                    nearestIndex = index
                }
            }
            
            current = remaining.remove(at: nearestIndex)
            path.append(current)
        }
        
        return path
    }
}
