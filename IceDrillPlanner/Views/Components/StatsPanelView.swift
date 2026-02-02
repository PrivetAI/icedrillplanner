import SwiftUI

struct StatsPanelView: View {
    let plan: FishingPlan
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toggle button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(AppTheme.primary)
                    
                    Text("Статистика")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    // Quick stats
                    if !isExpanded {
                        HStack(spacing: AppTheme.paddingMedium) {
                            QuickStat(value: "\(plan.totalHoles)", label: "лунок")
                            QuickStat(value: "\(plan.drilledHoles)", label: "пробур.")
                            QuickStat(value: "\(plan.totalCatches)", label: "улов")
                        }
                    }
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(AppTheme.textMuted)
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
                .padding(AppTheme.paddingMedium)
            }
            
            // Expanded content
            if isExpanded {
                Divider()
                    .background(AppTheme.cardBackgroundLight)
                
                VStack(spacing: AppTheme.paddingMedium) {
                    // Main stats grid
                    HStack(spacing: AppTheme.paddingMedium) {
                        StatCard(
                            icon: "circle.dotted",
                            title: "Всего лунок",
                            value: "\(plan.totalHoles)",
                            color: AppTheme.holePlanned
                        )
                        
                        StatCard(
                            icon: "checkmark.circle",
                            title: "Пробурено",
                            value: "\(plan.drilledHoles)",
                            color: AppTheme.holeDrilled
                        )
                        
                        StatCard(
                            icon: "fish.fill",
                            title: "Улов",
                            value: "\(plan.totalCatches)",
                            color: AppTheme.holeCaught
                        )
                    }
                    
                    // Distance stats
                    HStack(spacing: AppTheme.paddingMedium) {
                        StatCard(
                            icon: "ruler",
                            title: "Мин. расст.",
                            value: String(format: "%.1f м", plan.minDistance),
                            color: AppTheme.accent
                        )
                        
                        StatCard(
                            icon: "ruler",
                            title: "Сред. расст.",
                            value: String(format: "%.1f м", plan.averageDistance),
                            color: AppTheme.primary
                        )
                        
                        StatCard(
                            icon: "square.dashed",
                            title: "Покрытие",
                            value: String(format: "%.0f%%", plan.coveragePercent),
                            color: AppTheme.success
                        )
                    }
                    
                    // Zone info
                    HStack {
                        Label(plan.zone.displaySize, systemImage: plan.zone.shape.icon)
                        Spacer()
                        Label("\(Int(plan.zone.area)) м²", systemImage: "square.dashed")
                        Spacer()
                        Label(plan.pattern.displayName, systemImage: plan.pattern.icon)
                    }
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding(AppTheme.paddingMedium)
            }
        }
        .background(AppTheme.cardBackground)
    }
}

// MARK: - Quick Stat
struct QuickStat: View {
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.paddingSmall)
        .background(AppTheme.cardBackgroundLight)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

#Preview {
    VStack {
        Spacer()
        StatsPanelView(plan: {
            var plan = FishingPlan()
            plan.holes = PatternGenerator.generateHoles(
                pattern: .grid,
                zone: plan.zone,
                count: 15,
                spacing: 5
            )
            return plan
        }())
    }
    .background(AppTheme.background)
}
