import SwiftUI

struct FishSelectionView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.paddingLarge) {
                Text("Select Target Fish")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.paddingMedium) {
                    ForEach(FishType.allCases) { fish in
                        FishCard(
                            fish: fish,
                            isSelected: viewModel.currentPlan.targetFish == fish
                        ) {
                            viewModel.setTargetFish(fish)
                        }
                    }
                }
                
                // Selected fish info
                if viewModel.currentPlan.targetFish != .mixed {
                    FishInfoCard(fish: viewModel.currentPlan.targetFish)
                }
            }
            .padding(AppTheme.paddingLarge)
        }
    }
}

// MARK: - Fish Card
struct FishCard: View {
    let fish: FishType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.paddingSmall) {
                Text(fish.emoji)
                    .font(.system(size: 36))
                
                Text(fish.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
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

// MARK: - Fish Info Card
struct FishInfoCard: View {
    let fish: FishType
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
            HStack {
                Text(fish.emoji)
                    .font(.title2)
                Text(fish.displayName)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Text(fish.description)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            
            Divider()
                .background(AppTheme.cardBackgroundLight)
            
            HStack(spacing: AppTheme.paddingLarge) {
                VStack(alignment: .leading) {
                    Text("Recommended Pattern")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                    HStack {
                        Image(systemName: fish.recommendedPattern.icon)
                        Text(fish.recommendedPattern.displayName)
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Spacing")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                    Text("\(Int(fish.recommendedSpacing)) m")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
        .padding(AppTheme.paddingMedium)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

#Preview {
    FishSelectionView(viewModel: PlannerViewModel())
}
