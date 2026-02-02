import Foundation
import SwiftUI

// MARK: - Planner ViewModel
@MainActor
class PlannerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPlan: FishingPlan = FishingPlan()
    @Published var savedPlans: [FishingPlan] = []
    @Published var settings: AppSettings = AppSettings()
    
    // Wizard state
    @Published var wizardStep: Int = 0
    @Published var selectedHole: Hole?
    @Published var showHoleDetail: Bool = false
    
    // Map state
    @Published var mapScale: Double = 1.0
    @Published var mapOffset: CGSize = .zero
    
    private let storage = StorageManager.shared
    
    // MARK: - Init
    init() {
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        savedPlans = storage.loadPlans()
        settings = storage.loadSettings()
    }
    
    // MARK: - Zone Configuration
    func setZoneShape(_ shape: ZoneShape) {
        currentPlan.zone.shape = shape
    }
    
    func setZoneDimensions(width: Double, height: Double) {
        currentPlan.zone.width = width
        currentPlan.zone.height = height
    }
    
    func setZoneConditions(depth: Double, iceThickness: Double) {
        currentPlan.zone.depth = depth
        currentPlan.zone.iceThickness = iceThickness
    }
    
    // MARK: - Fish & Pattern Selection
    func setTargetFish(_ fish: FishType) {
        currentPlan.targetFish = fish
        currentPlan.spacing = fish.recommendedSpacing
        currentPlan.pattern = fish.recommendedPattern
    }
    
    func setPattern(_ pattern: HolePattern) {
        currentPlan.pattern = pattern
    }
    
    func setSpacing(_ spacing: Double) {
        currentPlan.spacing = spacing
    }
    
    // MARK: - Hole Generation
    func generateHoles(count: Int? = nil) {
        let holeCount = count ?? settings.defaultHoleCount
        currentPlan.holes = PatternGenerator.generateHoles(
            pattern: currentPlan.pattern,
            zone: currentPlan.zone,
            count: holeCount,
            spacing: currentPlan.spacing
        )
    }
    
    func regenerateHoles() {
        generateHoles(count: currentPlan.holes.count > 0 ? currentPlan.holes.count : nil)
    }
    
    // MARK: - Hole Management
    func selectHole(_ hole: Hole) {
        selectedHole = hole
        showHoleDetail = true
    }
    
    func updateHoleStatus(_ hole: Hole, status: HoleStatus) {
        currentPlan.updateHole(id: hole.id) { h in
            h.status = status
        }
        if selectedHole?.id == hole.id {
            selectedHole?.status = status
        }
    }
    
    func updateHoleNotes(_ hole: Hole, notes: String) {
        currentPlan.updateHole(id: hole.id) { h in
            h.notes = notes
        }
    }
    
    func addCatch(_ hole: Hole) {
        currentPlan.updateHole(id: hole.id) { h in
            h.catches += 1
            h.status = .caught
        }
    }
    
    func moveHole(_ hole: Hole, to position: CGPoint, scale: Double) {
        let x = Double(position.x) / scale
        let y = Double(position.y) / scale
        currentPlan.updateHole(id: hole.id) { h in
            h.x = x
            h.y = y
        }
    }
    
    func deleteHole(_ hole: Hole) {
        currentPlan.holes.removeAll { $0.id == hole.id }
        // Renumber
        for i in 0..<currentPlan.holes.count {
            currentPlan.holes[i].number = i + 1
        }
        showHoleDetail = false
        selectedHole = nil
    }
    
    func addHole(at position: CGPoint, scale: Double) {
        let x = Double(position.x) / scale
        let y = Double(position.y) / scale
        let newHole = Hole(
            number: currentPlan.holes.count + 1,
            x: x,
            y: y
        )
        currentPlan.holes.append(newHole)
    }
    
    // MARK: - Plan Management
    func savePlan(name: String? = nil) {
        if let name = name {
            currentPlan.name = name
        }
        currentPlan.updatedAt = Date()
        
        if savedPlans.contains(where: { $0.id == currentPlan.id }) {
            storage.updatePlan(currentPlan)
        } else {
            storage.addPlan(currentPlan)
        }
        loadData()
    }
    
    func loadPlan(_ plan: FishingPlan) {
        currentPlan = plan
        wizardStep = 3 // Go to map
    }
    
    func deletePlan(_ plan: FishingPlan) {
        storage.deletePlan(id: plan.id)
        loadData()
    }
    
    func newPlan() {
        currentPlan = FishingPlan()
        currentPlan.spacing = settings.defaultSpacing
        wizardStep = 0
        mapScale = 1.0
        mapOffset = .zero
        selectedHole = nil
    }
    
    // MARK: - Settings
    func saveSettings() {
        storage.saveSettings(settings)
    }
    
    // MARK: - Wizard Navigation
    func nextStep() {
        if wizardStep < 3 {
            wizardStep += 1
            if wizardStep == 3 {
                generateHoles()
            }
        }
    }
    
    func previousStep() {
        if wizardStep > 0 {
            wizardStep -= 1
        }
    }
    
    func goToMap() {
        generateHoles()
        wizardStep = 3
    }
}
