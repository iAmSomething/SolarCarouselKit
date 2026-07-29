import SwiftUI

// MARK: - View + CarouselKit Extension

/// SwiftUI `View`에 SolarCarouselKit의 wrapper modifier를 추가하는 확장
///
/// ## Quick View
/// - **역할**: `.carouselKit(.heroBanner())` 처럼 기존 ScrollView에 Carousel 스타일을 적용합니다.
/// - **사용처**: 이미 존재하는 `ScrollView + LazyHStack` 구조에 Carousel 동작을 추가할 때.
///   새로운 Carousel을 처음부터 만들 때는 `SolarCarouselView`를 사용하는 것을 권장합니다.
///
/// ## 사용 예시
/// ```swift
/// ScrollView(.horizontal) {
///     LazyHStack { ForEach(items) { ItemCard($0) } }
/// }
/// .carouselKit(.heroBanner())
/// ```
public extension View {

    /// HeroBanner 스타일 캐러셀 동작을 적용합니다.
    ///
    /// - Parameters:
    ///   - peekAmount: 양옆에 보이는 인접 카드 크기 (기본값: 전역 설정)
    /// - Returns: 수정된 뷰
    func carouselKitHeroBanner(peekAmount: CGFloat? = nil) -> some View {
        let peek = peekAmount ?? CarouselKit.configuration.defaultPeekAmount
        return self
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, peek, for: .scrollContent)
    }

    /// FullPager 스타일 캐러셀 동작을 적용합니다 (전체 화면 페이징).
    func carouselKitFullPager() -> some View {
        self.scrollTargetBehavior(.viewAligned)
    }

    /// CardStack / CoverFlow 등 커스텀 전환 효과와 함께 캐러셀 동작을 적용합니다.
    ///
    /// - Parameters:
    ///   - peekAmount: 양옆에 보이는 인접 카드 크기 (기본값: 전역 설정)
    /// - Returns: 수정된 뷰
    func carouselKitSnapping(peekAmount: CGFloat? = nil) -> some View {
        let peek = peekAmount ?? CarouselKit.configuration.defaultPeekAmount
        return self
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, peek, for: .scrollContent)
    }
}

// MARK: - 카드 전환 효과 View Extension

public extension View {

    /// HeroBanner 스타일 scrollTransition 효과를 카드에 적용합니다.
    ///
    /// - Parameter minScale: 비활성 시 최소 scale (기본값: 0.92)
    func carouselTransitionHeroBanner(minScale: CGFloat = 0.92) -> some View {
        self.scrollTransition { view, phase in
            view
                .scaleEffect(phase.isIdentity ? 1.0 : minScale)
                .opacity(phase.isIdentity ? 1.0 : 0.75)
        }
    }

    /// CardStack 스타일 scrollTransition 효과를 카드에 적용합니다.
    ///
    /// - Parameter depth: 비활성 카드의 최소 scale (기본값: 0.85)
    func carouselTransitionCardStack(depth: CGFloat = 0.85) -> some View {
        let minDepth = depth  // let 캡처 (Swift 6 Safe)
        return self.scrollTransition { view, phase in
            view
                .scaleEffect(phase.isIdentity ? 1.0 : minDepth)
                .opacity(phase.isIdentity ? 1.0 : 0.55)
                .offset(y: phase.isIdentity ? 0 : 10)
        }
    }

    /// CoverFlow 스타일 3D 회전 scrollTransition 효과를 카드에 적용합니다.
    ///
    /// - Parameters:
    ///   - rotation: 비활성 카드의 최대 회전 각도 (기본값: 40도)
    ///   - perspective: 원근감 강도 (기본값: 0.5)
    func carouselTransitionCoverFlow(rotation: Double = 40, perspective: CGFloat = 0.5) -> some View {
        let rot = rotation    // let 캡처 (Swift 6 Safe)
        let persp = perspective  // let 캡처 (Swift 6 Safe)
        return self.scrollTransition { view, phase in
            let angle: Double = phase.isIdentity ? 0
                : (phase == .topLeading ? rot : -rot)
            return view
                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: persp)
                .opacity(phase.isIdentity ? 1.0 : 0.6)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
        }
    }

    /// Spotlight 스타일 강조 scrollTransition 효과를 카드에 적용합니다.
    ///
    /// - Parameter minOpacity: 비활성 카드의 최소 불투명도 (기본값: 0.5)
    func carouselTransitionSpotlight(minOpacity: Double = 0.5) -> some View {
        self.scrollTransition { view, phase in
            view
                .opacity(phase.isIdentity ? 1.0 : minOpacity)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.94)
                .blur(radius: phase.isIdentity ? 0 : 1.5)
        }
    }
}
