import SwiftUI

struct BrandLogoView: View {
    let size: CGFloat
    let cornerRadius: CGFloat

    init(size: CGFloat, cornerRadius: CGFloat? = nil) {
        self.size = size
        self.cornerRadius = cornerRadius ?? (size * 0.22)
    }

    var body: some View {
        Image("LitLock")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// Custom Button Component
struct CustomButton: View {
    let title: String
    let icon: String?
    let variant: ButtonVariant
    let action: () -> Void

    enum ButtonVariant {
        case primary
        case secondary
        case tertiary
        case glass
        case outline
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }
                Text(title)
                    .font(.lexendBody(17, weight: .semibold))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(backgroundView)
            .foregroundColor(textColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }

    @ViewBuilder
    var backgroundView: some View {
        switch variant {
        case .primary:
            LinearGradient(
                colors: [Color.primary, Color.primaryContainer],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            Color.secondaryContainer
        case .tertiary:
            Color.tertiaryContainer
        case .glass:
            Color.white.opacity(0.2)
        case .outline:
            Color.clear
        }
    }

    var textColor: Color {
        switch variant {
        case .primary:
            return .white
        case .secondary:
            return Color.onSecondaryContainer
        case .tertiary:
            return Color.onTertiaryContainer
        case .glass, .outline:
            return Color.onSurface
        }
    }

    var borderColor: Color {
        variant == .outline ? Color.outline : Color.clear
    }

    var borderWidth: CGFloat {
        variant == .outline ? 2 : 0
    }
}

// Progress Bar Component
struct ProgressBarView: View {
    let progress: Double
    let label: String
    let sublabel: String?

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.lexendBody(14, weight: .medium))
                    .foregroundColor(Color.onSurfaceVariant)
                Spacer()
                Text("\(Int(progress))%")
                    .font(.lexendBody(14, weight: .bold))
                    .foregroundColor(Color.tertiary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceContainer)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.tertiary, Color.tertiaryContainer],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (animatedProgress / 100), height: 8)
                }
            }
            .frame(height: 8)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animatedProgress = progress
                }
            }

            if let sublabel = sublabel {
                Text(sublabel)
                    .font(.lexendBody(12, weight: .regular))
                    .foregroundColor(Color.onSurfaceVariant)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .popUpShadow()
    }
}

// Nav Pill Component
struct NavPill: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isActive ? 24 : 20, weight: .medium))
                Text(label)
                    .font(.lexendBody(isActive ? 12 : 10, weight: isActive ? .semibold : .medium))
            }
            .foregroundColor(isActive ? .white : Color.onSurface)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isActive ?
                    LinearGradient(
                        colors: [Color.primary, Color.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(colors: [Color.surfaceContainerLow], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(20)
            .popUpShadow()
        }
        .scaleEffect(isPressed ? 0.95 : (isActive ? 1.05 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
    }
}

// Animated Pulsing Dot Indicator
struct PulsingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(animating ? 0.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}
