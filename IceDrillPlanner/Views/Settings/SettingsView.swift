import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            List {
                // Default settings
                Section {
                    HStack {
                        Label("Расстояние по умолчанию", systemImage: "ruler")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Stepper(
                            "\(Int(viewModel.settings.defaultSpacing)) м",
                            value: $viewModel.settings.defaultSpacing,
                            in: 2...20,
                            step: 1
                        )
                        .labelsHidden()
                    }
                    
                    HStack {
                        Label("Лунок по умолчанию", systemImage: "number")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Stepper(
                            "\(viewModel.settings.defaultHoleCount)",
                            value: $viewModel.settings.defaultHoleCount,
                            in: 5...50,
                            step: 5
                        )
                        .labelsHidden()
                    }
                } header: {
                    Text("Настройки по умолчанию")
                }
                .listRowBackground(AppTheme.cardBackground)
                
                // Display settings
                Section {
                    Toggle(isOn: $viewModel.settings.showDistances) {
                        Label("Показывать расстояния", systemImage: "arrow.left.and.right")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.primary)
                    
                    Toggle(isOn: $viewModel.settings.showGrid) {
                        Label("Показывать сетку", systemImage: "grid")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.primary)
                    
                    Toggle(isOn: $viewModel.settings.useMetricUnits) {
                        Label("Метрическая система", systemImage: "ruler")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.primary)
                } header: {
                    Text("Отображение")
                }
                .listRowBackground(AppTheme.cardBackground)
                
                // About
                Section {
                    HStack {
                        Label("Версия", systemImage: "info.circle")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppTheme.textMuted)
                    }
                } header: {
                    Text("О приложении")
                } footer: {
                    Text("Ice Drill Pattern Planner — профессиональный инструмент для планирования расстановки лунок на льду.")
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
                    Text("Легенда цветов")
                }
                .listRowBackground(AppTheme.cardBackground)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Настройки")
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
