import SwiftUI

struct PatternSelectionView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.paddingLarge) {
                // Pattern selection
                VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                    Text("Hole Pattern")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppTheme.paddingMedium) {
                        ForEach(HolePattern.allCases) { pattern in
                            PatternCard(
                                pattern: pattern,
                                isSelected: viewModel.currentPlan.pattern == pattern
                            ) {
                                viewModel.setPattern(pattern)
                            }
                        }
                    }
                }
                
                // Spacing slider
                VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                    Text("Hole Spacing")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    SpacingSlider(value: $viewModel.currentPlan.spacing)
                }
                
                // Summary
                PlanSummaryCard(plan: viewModel.currentPlan)
            }
            .padding(AppTheme.paddingLarge)
        }
    }
}

// MARK: - Pattern Card
struct PatternCard: View {
    let pattern: HolePattern
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.paddingSmall) {
                Image(systemName: pattern.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textMuted)
                
                Text(pattern.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                
                Text(pattern.preview)
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(AppTheme.textMuted)
                    .lineLimit(3)
                    .frame(height: 30)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.paddingMedium)
            .background(isSelected ? AppTheme.cardBackgroundLight : AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(isSelected ? AppTheme.primary : Color.clear, lineWidth: 2)
            }
        }
    }
}

// MARK: - Spacing Slider
struct SpacingSlider: View {
    @Binding var value: Double
    
    let presets: [(String, Double)] = [
        ("Close", 3),
        ("Medium", 5),
        ("Far", 10),
        ("Very Far", 15)
    ]
    
    var body: some View {
        VStack(spacing: AppTheme.paddingMedium) {
            // Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Spacing")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", value)) m")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.primary)
                }
                
                Slider(value: $value, in: 2...20, step: 0.5)
                    .tint(AppTheme.primary)
            }
            .padding(AppTheme.paddingMedium)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusSmall)
            
            // Presets
            HStack(spacing: AppTheme.paddingSmall) {
                ForEach(presets, id: \.1) { preset in
                    Button {
                        value = preset.1
                    } label: {
                        Text(preset.0)
                            .font(.caption)
                            .foregroundColor(abs(value - preset.1) < 0.5 ? AppTheme.textPrimary : AppTheme.textMuted)
                            .padding(.horizontal, AppTheme.paddingSmall)
                            .padding(.vertical, 6)
                            .background(abs(value - preset.1) < 0.5 ? AppTheme.primary.opacity(0.3) : AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                    }
                }
            }
        }
    }
}

// MARK: - Plan Summary Card
struct PlanSummaryCard: View {
    let plan: FishingPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
            Text("Summary")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppTheme.paddingSmall) {
                SummaryRow(icon: plan.zone.shape.icon, title: "Zone", value: plan.zone.displaySize)
                SummaryRow(icon: "square.dashed", title: "Area", value: "\(Int(plan.zone.area)) m²")
                SummaryRow(icon: plan.targetFish.emoji, title: "Fish", value: plan.targetFish.displayName)
                SummaryRow(icon: plan.pattern.icon, title: "Pattern", value: plan.pattern.displayName)
                SummaryRow(icon: "ruler", title: "Spacing", value: "\(String(format: "%.1f", plan.spacing)) m")
            }
            .padding(AppTheme.paddingMedium)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            if icon.count <= 2 {
                Text(icon)
            } else {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.textMuted)
            }
            Text(title)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    PatternSelectionView(viewModel: PlannerViewModel())
}
