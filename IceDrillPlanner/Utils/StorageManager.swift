import Foundation

// MARK: - Storage Manager
class StorageManager {
    static let shared = StorageManager()
    
    private let plansKey = "saved_fishing_plans"
    private let settingsKey = "app_settings"
    
    private init() {}
    
    // MARK: - Plans
    func savePlans(_ plans: [FishingPlan]) {
        if let encoded = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(encoded, forKey: plansKey)
        }
    }
    
    func loadPlans() -> [FishingPlan] {
        guard let data = UserDefaults.standard.data(forKey: plansKey),
              let plans = try? JSONDecoder().decode([FishingPlan].self, from: data) else {
            return []
        }
        return plans
    }
    
    func addPlan(_ plan: FishingPlan) {
        var plans = loadPlans()
        plans.insert(plan, at: 0)
        savePlans(plans)
    }
    
    func updatePlan(_ plan: FishingPlan) {
        var plans = loadPlans()
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
            savePlans(plans)
        }
    }
    
    func deletePlan(id: UUID) {
        var plans = loadPlans()
        plans.removeAll { $0.id == id }
        savePlans(plans)
    }
    
    // MARK: - Settings
    func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }
}

// MARK: - App Settings
struct AppSettings: Codable, Equatable {
    var defaultSpacing: Double = 5.0
    var defaultHoleCount: Int = 15
    var showDistances: Bool = true
    var showGrid: Bool = false
    var useMetricUnits: Bool = true
}
