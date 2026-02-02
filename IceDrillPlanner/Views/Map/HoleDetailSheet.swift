import SwiftUI

struct HoleDetailSheet: View {
    @ObservedObject var viewModel: PlannerViewModel
    let hole: Hole
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.paddingLarge) {
                        // Header
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(hole.status.color)
                                    .frame(width: 60, height: 60)
                                
                                Text("\(hole.number)")
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hole #\(hole.number)")
                                    .font(.title2.bold())
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text(hole.status.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(hole.status.color)
                            }
                            
                            Spacer()
                        }
                        
                        // Position info
                        HStack(spacing: AppTheme.paddingLarge) {
                            InfoBadge(
                                icon: "location",
                                title: "Position",
                                value: "X: \(String(format: "%.1f", hole.x))m\nY: \(String(format: "%.1f", hole.y))m"
                            )
                            
                            if let depth = hole.depth {
                                InfoBadge(
                                    icon: "water.waves",
                                    title: "Depth",
                                    value: "\(String(format: "%.1f", depth))m"
                                )
                            }
                            
                            InfoBadge(
                                icon: "fish.fill",
                                title: "Catch",
                                value: "\(hole.catches)"
                            )
                        }
                        
                        // Status selection
                        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                            Text("Status")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: AppTheme.paddingSmall) {
                                ForEach(HoleStatus.allCases) { status in
                                    StatusButton(
                                        status: status,
                                        isSelected: hole.status == status
                                    ) {
                                        viewModel.updateHoleStatus(hole, status: status)
                                    }
                                }
                            }
                        }
                        
                        // Quick actions
                        HStack(spacing: AppTheme.paddingMedium) {
                            ActionButton(
                                icon: "fish.fill",
                                title: "Caught!",
                                color: AppTheme.holeCaught
                            ) {
                                viewModel.addCatch(hole)
                            }
                            
                            ActionButton(
                                icon: "checkmark.circle",
                                title: "Drilled",
                                color: AppTheme.holeDrilled
                            ) {
                                viewModel.updateHoleStatus(hole, status: .drilled)
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            TextEditor(text: $notes)
                                .frame(height: 80)
                                .padding(AppTheme.paddingSmall)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadiusSmall)
                                .foregroundColor(AppTheme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .onChange(of: notes) { _, newValue in
                                    viewModel.updateHoleNotes(hole, notes: newValue)
                                }
                        }
                        
                        // Delete button
                        Button(role: .destructive) {
                            viewModel.deleteHole(hole)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Hole")
                            }
                            .font(.headline)
                            .foregroundColor(AppTheme.danger)
                            .frame(maxWidth: .infinity)
                            .padding(AppTheme.paddingMedium)
                            .background(AppTheme.danger.opacity(0.15))
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                        }
                    }
                    .padding(AppTheme.paddingLarge)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
            .onAppear {
                notes = hole.notes
            }
        }
    }
}

// MARK: - Info Badge
struct InfoBadge: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textMuted)
            
            Text(value)
                .font(.caption.bold())
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.paddingSmall)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

// MARK: - Status Button
struct StatusButton: View {
    let status: HoleStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: status.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? status.color : AppTheme.textMuted)
                
                Text(status.displayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.paddingSmall)
            .background(isSelected ? status.color.opacity(0.2) : AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusSmall)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .stroke(isSelected ? status.color : Color.clear, lineWidth: 1)
            }
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption.bold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.paddingMedium)
            .background(color)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
}

#Preview {
    HoleDetailSheet(
        viewModel: PlannerViewModel(),
        hole: Hole(number: 1, x: 10, y: 15, status: .drilled)
    )
}
