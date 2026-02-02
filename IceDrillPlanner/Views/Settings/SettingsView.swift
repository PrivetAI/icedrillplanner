import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            List {
                // Display settings
                Section {
                    Toggle(isOn: $viewModel.settings.showDistances) {
                        Label("Show Distances", systemImage: "arrow.left.and.right")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.primary)
                    
                    Toggle(isOn: $viewModel.settings.showGrid) {
                        Label("Show Grid", systemImage: "grid")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.primary)
                    
                    Toggle(isOn: $viewModel.settings.useMetricUnits) {
                        Label("Metric Units", systemImage: "ruler")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.primary)
                } header: {
                    Text("Display")
                }
                .listRowBackground(AppTheme.cardBackground)
                
                // About
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppTheme.textMuted)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("Ice Drill Pattern Planner — professional tool for planning ice fishing hole layouts.")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.cardBackground)
                
                // Legend
                Section {
                    ForEach(HoleStatus.allCases) { status in
                        HStack {
                            Circle()
                                .fill(status.color)
                                .frame(width: 20, height: 20)
                            Text(status.displayName)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                } header: {
                    Text("Color Legend")
                }
                .listRowBackground(AppTheme.cardBackground)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: viewModel.settings) { _, _ in
            viewModel.saveSettings()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: PlannerViewModel())
    }
}
