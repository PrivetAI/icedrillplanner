import SwiftUI

struct SavedPlansView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @Binding var selectedTab: Int
    @State private var showDeleteAlert = false
    @State private var planToDelete: FishingPlan?
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            if viewModel.savedPlans.isEmpty {
                EmptyPlansView {
                    selectedTab = 0
                    viewModel.newPlan()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.paddingMedium) {
                        ForEach(viewModel.savedPlans) { plan in
                            PlanCard(plan: plan) {
                                viewModel.loadPlan(plan)
                                selectedTab = 0
                            } onDelete: {
                                planToDelete = plan
                                showDeleteAlert = true
                            }
                        }
                    }
                    .padding(AppTheme.paddingLarge)
                }
            }
        }
        .navigationTitle("Мои планы")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Удалить план?", isPresented: $showDeleteAlert) {
            Button("Отмена", role: .cancel) {}
            Button("Удалить", role: .destructive) {
                if let plan = planToDelete {
                    viewModel.deletePlan(plan)
                }
            }
        } message: {
            Text("Это действие нельзя отменить")
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Empty Plans View
struct EmptyPlansView: View {
    let onCreateNew: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.paddingLarge) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textMuted)
            
            Text("Нет сохранённых планов")
                .font(.title3.bold())
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Создайте первый план расстановки лунок")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: onCreateNew) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Создать план")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.paddingXLarge)
                .padding(.vertical, AppTheme.paddingMedium)
                .background(AppTheme.iceGradient)
                .cornerRadius(AppTheme.cornerRadiusLarge)
            }
        }
        .padding(AppTheme.paddingLarge)
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: FishingPlan
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(plan.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    // Mini preview
                    MiniMapPreview(plan: plan)
                        .frame(width: 60, height: 60)
                }
                
                Divider()
                    .background(AppTheme.cardBackgroundLight)
                
                // Stats
                HStack(spacing: AppTheme.paddingLarge) {
                    PlanStat(icon: "circle.dotted", value: "\(plan.totalHoles)", label: "лунок")
                    PlanStat(icon: plan.pattern.icon, value: plan.pattern.displayName, label: "паттерн")
                    PlanStat(icon: "ruler", value: "\(Int(plan.spacing))м", label: "шаг")
                    PlanStat(icon: "fish.fill", value: "\(plan.totalCatches)", label: "улов")
                }
                
                // Zone info
                HStack {
                    Label(plan.zone.displaySize, systemImage: plan.zone.shape.icon)
                    Spacer()
                    Label(plan.targetFish.displayName, systemImage: "")
                    Text(plan.targetFish.emoji)
                }
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            }
            .padding(AppTheme.paddingMedium)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .contextMenu {
            Button {
                onTap()
            } label: {
                Label("Открыть", systemImage: "folder")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

// MARK: - Plan Stat
struct PlanStat: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(AppTheme.primary)
                Text(value)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.textPrimary)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

// MARK: - Mini Map Preview
struct MiniMapPreview: View {
    let plan: FishingPlan
    
    var body: some View {
        GeometryReader { geo in
            let zone = plan.zone
            let maxDim = max(
                zone.shape == .rectangle ? zone.width : zone.height * 2,
                zone.shape == .rectangle ? zone.height : zone.height * 2
            )
            let scale = min(geo.size.width, geo.size.height) / maxDim * 0.9
            
            ZStack {
                // Zone shape
                if zone.shape == .rectangle {
                    Rectangle()
                        .fill(AppTheme.iceMedium.opacity(0.2))
                        .frame(
                            width: CGFloat(zone.width * scale),
                            height: CGFloat(zone.height * scale)
                        )
                } else {
                    Circle()
                        .fill(AppTheme.iceMedium.opacity(0.2))
                        .frame(
                            width: CGFloat(zone.height * 2 * scale),
                            height: CGFloat(zone.height * 2 * scale)
                        )
                }
                
                // Holes
                ForEach(plan.holes) { hole in
                    Circle()
                        .fill(hole.status.color)
                        .frame(width: 4, height: 4)
                        .offset(
                            x: CGFloat((hole.x - maxDim / 2) * scale),
                            y: CGFloat((hole.y - maxDim / 2) * scale)
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(AppTheme.cardBackgroundLight)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

#Preview {
    NavigationStack {
        SavedPlansView(viewModel: PlannerViewModel(), selectedTab: .constant(1))
    }
}
