import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PlannerViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // New Plan / Current Plan
            NavigationStack {
                if viewModel.wizardStep < 3 {
                    NewPlanView(viewModel: viewModel)
                } else {
                    MapView(viewModel: viewModel)
                }
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Новый план")
            }
            .tag(0)
            
            // Saved Plans
            NavigationStack {
                SavedPlansView(viewModel: viewModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "folder.fill")
                Text("Мои планы")
            }
            .tag(1)
            
            // Settings
            NavigationStack {
                SettingsView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Настройки")
            }
            .tag(2)
        }
        .tint(AppTheme.primary)
    }
}

#Preview {
    ContentView()
}
