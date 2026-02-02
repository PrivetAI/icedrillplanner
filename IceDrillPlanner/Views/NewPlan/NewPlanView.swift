import SwiftUI

struct NewPlanView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                StepProgressView(currentStep: viewModel.wizardStep)
                    .padding(.horizontal, AppTheme.paddingLarge)
                    .padding(.top, AppTheme.paddingMedium)
                
                // Step content
                TabView(selection: $viewModel.wizardStep) {
                    ZoneSetupView(viewModel: viewModel)
                        .tag(0)
                    
                    FishSelectionView(viewModel: viewModel)
                        .tag(1)
                    
                    PatternSelectionView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.wizardStep)
                
                // Navigation buttons
                HStack(spacing: AppTheme.paddingMedium) {
                    if viewModel.wizardStep > 0 {
                        Button {
                            viewModel.previousStep()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.paddingMedium)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                        }
                    }
                    
                    Button {
                        if viewModel.wizardStep < 2 {
                            viewModel.nextStep()
                        } else {
                            viewModel.goToMap()
                        }
                    } label: {
                        HStack {
                            Text(viewModel.wizardStep < 2 ? "Next" : "Create Plan")
                            Image(systemName: viewModel.wizardStep < 2 ? "chevron.right" : "checkmark")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.paddingMedium)
                        .background(AppTheme.iceGradient)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, AppTheme.paddingLarge)
            }
        }
        .navigationTitle("New Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Step Progress View
struct StepProgressView: View {
    let currentStep: Int
    let steps = ["Zone", "Fish", "Pattern"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                HStack(spacing: 4) {
                    Circle()
                        .fill(index <= currentStep ? AppTheme.primary : AppTheme.cardBackground)
                        .frame(width: 28, height: 28)
                        .overlay {
                            if index < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundColor(index == currentStep ? .white : AppTheme.textMuted)
                            }
                        }
                    
                    Text(steps[index])
                        .font(.caption)
                        .foregroundColor(index <= currentStep ? AppTheme.textPrimary : AppTheme.textMuted)
                }
                
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(index < currentStep ? AppTheme.primary : AppTheme.cardBackground)
                        .frame(height: 2)
                }
            }
        }
        .padding(.vertical, AppTheme.paddingSmall)
    }
}

// MARK: - Zone Setup View
struct ZoneSetupView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.paddingLarge) {
                // Shape selection
                VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                    Text("Zone Shape")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: AppTheme.paddingMedium) {
                        ForEach(ZoneShape.allCases) { shape in
                            ShapeCard(
                                shape: shape,
                                isSelected: viewModel.currentPlan.zone.shape == shape
                            ) {
                                viewModel.setZoneShape(shape)
                            }
                        }
                    }
                }
                
                // Dimensions
                VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                    Text("Dimensions")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if viewModel.currentPlan.zone.shape == .rectangle {
                        DimensionSlider(
                            title: "Length",
                            value: $viewModel.currentPlan.zone.width,
                            range: 10...200,
                            unit: "m"
                        )
                        
                        DimensionSlider(
                            title: "Width",
                            value: $viewModel.currentPlan.zone.height,
                            range: 10...200,
                            unit: "m"
                        )
                    } else {
                        DimensionSlider(
                            title: "Radius",
                            value: $viewModel.currentPlan.zone.height,
                            range: 5...100,
                            unit: "m"
                        )
                    }
                }
                
                // Conditions
                VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                    Text("Conditions")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    DimensionSlider(
                        title: "Water Depth",
                        value: $viewModel.currentPlan.zone.depth,
                        range: 1...50,
                        unit: "m"
                    )
                    
                    DimensionSlider(
                        title: "Ice Thickness",
                        value: $viewModel.currentPlan.zone.iceThickness,
                        range: 10...100,
                        unit: "cm"
                    )
                }
                
                // Preview
                ZonePreviewCard(zone: viewModel.currentPlan.zone)
            }
            .padding(AppTheme.paddingLarge)
        }
    }
}

// MARK: - Shape Card
struct ShapeCard: View {
    let shape: ZoneShape
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.paddingSmall) {
                Image(systemName: shape.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textMuted)
                
                Text(shape.displayName)
                    .font(.caption)
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

// MARK: - Dimension Slider
struct DimensionSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Text("\(Int(value)) \(unit)")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.primary)
            }
            
            Slider(value: $value, in: range, step: 1)
                .tint(AppTheme.primary)
        }
        .padding(AppTheme.paddingMedium)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

// MARK: - Zone Preview Card
struct ZonePreviewCard: View {
    let zone: FishingZone
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(zone.displaySize, systemImage: "ruler")
                    Label("Area: \(Int(zone.area)) m²", systemImage: "square.dashed")
                    Label("Depth: \(Int(zone.depth)) m", systemImage: "water.waves")
                    Label("Ice: \(Int(zone.iceThickness)) cm", systemImage: "snowflake")
                }
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                // Mini preview
                ZStack {
                    if zone.shape == .rectangle {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.iceMedium.opacity(0.3))
                            .frame(
                                width: min(80, CGFloat(zone.width / zone.height) * 60),
                                height: min(80, CGFloat(zone.height / zone.width) * 60)
                            )
                    } else {
                        Circle()
                            .fill(AppTheme.iceMedium.opacity(0.3))
                            .frame(width: 70, height: 70)
                    }
                }
                .frame(width: 100, height: 80)
            }
            .padding(AppTheme.paddingMedium)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
}

#Preview {
    NavigationStack {
        NewPlanView(viewModel: PlannerViewModel())
    }
}
