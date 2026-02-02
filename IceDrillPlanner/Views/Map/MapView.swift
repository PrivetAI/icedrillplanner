import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @State private var showSaveDialog = false
    @State private var planName = ""
    @State private var showPatternPicker = false
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Canvas
                ZoneCanvasView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Stats panel
                StatsPanelView(plan: viewModel.currentPlan)
            }
        }
        .navigationTitle(viewModel.currentPlan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.newPlan()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: AppTheme.paddingSmall) {
                    // Pattern picker
                    Menu {
                        ForEach(HolePattern.allCases) { pattern in
                            Button {
                                viewModel.setPattern(pattern)
                                viewModel.regenerateHoles()
                            } label: {
                                Label(pattern.displayName, systemImage: pattern.icon)
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.currentPlan.pattern.icon)
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    // Regenerate
                    Button {
                        viewModel.regenerateHoles()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    // Save
                    Button {
                        planName = viewModel.currentPlan.name
                        showSaveDialog = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
        }
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $viewModel.showHoleDetail) {
            if let hole = viewModel.selectedHole {
                HoleDetailSheet(viewModel: viewModel, hole: hole)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("Save Plan", isPresented: $showSaveDialog) {
            TextField("Plan Name", text: $planName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                viewModel.savePlan(name: planName)
            }
        } message: {
            Text("Enter a name for the plan")
        }
    }
}

// MARK: - Zone Canvas View
struct ZoneCanvasView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var draggedHole: Hole?
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            let zone = viewModel.currentPlan.zone
            let baseScale = GeometryUtils.calculateScale(
                zoneWidth: zone.shape == .rectangle ? zone.width : zone.height * 2,
                zoneHeight: zone.shape == .rectangle ? zone.height : zone.height * 2,
                canvasSize: geo.size
            )
            let currentScale = baseScale * scale
            
            ZStack {
                // Background grid
                GridBackgroundView()
                
                // Zone area
                ZoneShapeView(zone: zone, scale: currentScale)
                    .offset(x: offset.width, y: offset.height)
                
                // Holes
                ForEach(viewModel.currentPlan.holes) { hole in
                    HoleMarkerView(
                        hole: hole,
                        scale: currentScale,
                        isSelected: viewModel.selectedHole?.id == hole.id,
                        isDragging: draggedHole?.id == hole.id
                    )
                    .offset(
                        x: offset.width + (draggedHole?.id == hole.id ? dragOffset.width : 0),
                        y: offset.height + (draggedHole?.id == hole.id ? dragOffset.height : 0)
                    )
                    .onTapGesture {
                        viewModel.selectHole(hole)
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.3)
                            .sequenced(before: DragGesture())
                            .onChanged { value in
                                switch value {
                                case .first(true):
                                    draggedHole = hole
                                case .second(true, let drag):
                                    if let drag = drag {
                                        dragOffset = drag.translation
                                    }
                                default:
                                    break
                                }
                            }
                            .onEnded { value in
                                if let draggedHole = draggedHole {
                                    let newX = CGFloat(draggedHole.x) * currentScale + offset.width + dragOffset.width
                                    let newY = CGFloat(draggedHole.y) * currentScale + offset.height + dragOffset.height
                                    viewModel.moveHole(
                                        draggedHole,
                                        to: CGPoint(x: newX - offset.width, y: newY - offset.height),
                                        scale: currentScale
                                    )
                                }
                                self.draggedHole = nil
                                dragOffset = .zero
                            }
                    )
                }
                
                // Scale indicator
                ScaleIndicatorView(scale: currentScale)
                    .position(x: geo.size.width - 60, y: geo.size.height - 30)
            }
            .clipped()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { value in
                        lastScale = scale
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if draggedHole == nil {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .onTapGesture(count: 2) { location in
                // Double tap to add hole
                let adjustedLocation = CGPoint(
                    x: location.x - offset.width,
                    y: location.y - offset.height
                )
                viewModel.addHole(at: adjustedLocation, scale: currentScale)
            }
        }
    }
}

// MARK: - Grid Background
struct GridBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let gridSize: CGFloat = 30
                
                // Vertical lines
                var x: CGFloat = 0
                while x < size.width {
                    let path = Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(AppTheme.cardBackground), lineWidth: 1)
                    x += gridSize
                }
                
                // Horizontal lines
                var y: CGFloat = 0
                while y < size.height {
                    let path = Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(AppTheme.cardBackground), lineWidth: 1)
                    y += gridSize
                }
            }
        }
    }
}

// MARK: - Zone Shape View
struct ZoneShapeView: View {
    let zone: FishingZone
    let scale: Double
    
    var body: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            
            Group {
                if zone.shape == .rectangle {
                    let width = CGFloat(zone.width * scale)
                    let height = CGFloat(zone.height * scale)
                    
                    Rectangle()
                        .fill(AppTheme.iceMedium.opacity(0.15))
                        .frame(width: width, height: height)
                        .overlay {
                            Rectangle()
                                .stroke(AppTheme.primary.opacity(0.5), lineWidth: 2)
                        }
                        .position(x: centerX, y: centerY)
                } else {
                    let radius = CGFloat(zone.height * scale)
                    
                    Circle()
                        .fill(AppTheme.iceMedium.opacity(0.15))
                        .frame(width: radius * 2, height: radius * 2)
                        .overlay {
                            Circle()
                                .stroke(AppTheme.primary.opacity(0.5), lineWidth: 2)
                        }
                        .position(x: centerX, y: centerY)
                }
            }
        }
    }
}

// MARK: - Scale Indicator
struct ScaleIndicatorView: View {
    let scale: Double
    
    var body: some View {
        let metersPerUnit: Double = 10
        let width = metersPerUnit * scale
        
        VStack(spacing: 2) {
            Rectangle()
                .fill(AppTheme.textSecondary)
                .frame(width: CGFloat(width), height: 3)
            
            Text("\(Int(metersPerUnit))m")
                .font(.caption2)
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

#Preview {
    NavigationStack {
        MapView(viewModel: {
            let vm = PlannerViewModel()
            vm.generateHoles(count: 15)
            return vm
        }())
    }
}
