import SwiftUI

// MARK: - scrollTransition 효과 컬렉션

/// `scrollTransition` 기반의 재사용 가능한 카드 전환 효과 모음
///
/// ## Quick View
/// - **역할**: 각 Carousel Preset에서 공유하는 `scrollTransition` 효과를 순수 함수로 제공합니다.
/// - **Swift 6 핵심**: 클로저 내부에서 외부 mutable 상태를 **절대 캡처하지 않습니다**.
///   `phase` 파라미터만 사용하므로 Actor 격리 문제가 발생하지 않습니다.
///
/// ## 사용 예시
/// ```swift
/// CardView()
///     .scrollTransition(CarouselTransitions.cardStack())
/// ```
public enum CarouselTransitions {

    // MARK: - Hero Banner 전환 효과

    /// HeroBanner 스타일 전환: 비활성 카드가 약간 축소되고 투명해집니다.
    ///
    /// - Parameter minScale: 비활성 카드의 최소 크기 비율 (기본값: 0.92)
    public static func heroBanner(minScale: CGFloat = 0.92) -> some ViewModifier {
        HeroBannerTransitionModifier(minScale: minScale)
    }

    // MARK: - Card Stack 전환 효과

    /// CardStack 스타일 전환: 스케일 + 수직 이동으로 깊이감 표현.
    ///
    /// - Parameter minScale: 비활성 카드의 최소 크기 비율 (기본값: 0.85)
    public static func cardStack(minScale: CGFloat = 0.85) -> some ViewModifier {
        CardStackTransitionModifier(minScale: minScale)
    }

    // MARK: - Cover Flow 전환 효과 (3D 회전)

    /// CoverFlow 스타일 전환: 3D perspective rotation.
    ///
    /// - Parameter maxRotation: 비활성 카드의 최대 회전 각도 (기본값: 40도)
    /// - Parameter perspective: 원근감 강도 (기본값: 0.5)
    public static func coverFlow(maxRotation: Double = 40, perspective: CGFloat = 0.5) -> some ViewModifier {
        CoverFlowTransitionModifier(maxRotation: maxRotation, perspective: perspective)
    }

    // MARK: - Spotlight 전환 효과

    /// SpotlightFeed 스타일 전환: 중앙 카드가 강조되고 주변이 희미해집니다.
    ///
    /// - Parameter minOpacity: 비활성 카드의 최소 불투명도 (기본값: 0.5)
    public static func spotlight(minOpacity: Double = 0.5) -> some ViewModifier {
        SpotlightTransitionModifier(minOpacity: minOpacity)
    }
}

// MARK: - ViewModifiers

private struct HeroBannerTransitionModifier: ViewModifier {
    let minScale: CGFloat
    func body(content: Content) -> some View {
        content.scrollTransition { view, phase in
            view
                .scaleEffect(phase.isIdentity ? 1.0 : minScale)
                .opacity(phase.isIdentity ? 1.0 : 0.7)
        }
    }
}

private struct CardStackTransitionModifier: ViewModifier {
    let minScale: CGFloat
    func body(content: Content) -> some View {
        content.scrollTransition { view, phase in
            view
                .scaleEffect(phase.isIdentity ? 1.0 : minScale)
                .opacity(phase.isIdentity ? 1.0 : 0.6)
                .offset(y: phase.isIdentity ? 0 : 8)
        }
    }
}

private struct SpotlightTransitionModifier: ViewModifier {
    let minOpacity: Double
    func body(content: Content) -> some View {
        content.scrollTransition { view, phase in
            view
                .opacity(phase.isIdentity ? 1.0 : minOpacity)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                .blur(radius: phase.isIdentity ? 0 : 1.5)
        }
    }
}



// MARK: - CoverFlow 전용 3D 모디파이어

/// CoverFlow의 3D 회전 효과를 구현하는 전용 ViewModifier
private struct CoverFlowTransitionModifier: ViewModifier {
    let maxRotation: Double
    let perspective: CGFloat

    func body(content: Content) -> some View {
        content.scrollTransition { view, phase in
            // Swift 6 Safe: phase 값만 사용. 외부 mutable 상태 캡처 없음.
            let rotation: Double = phase.isIdentity ? 0 : (phase == .topLeading ? maxRotation : -maxRotation)
            let opacity: Double = phase.isIdentity ? 1.0 : 0.6
            let scale: CGFloat = phase.isIdentity ? 1.0 : 0.8

            return view
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: perspective
                )
                .opacity(opacity)
                .scaleEffect(y: scale)
        }
    }
}
