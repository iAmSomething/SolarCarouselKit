import SwiftUI

// MARK: - 페이지 인디케이터

/// 캐러셀의 현재 페이지를 시각적으로 표현하는 커스텀 인디케이터
///
/// ## Quick View
/// - **역할**: 표준 `UIPageControl`보다 훨씬 풍부한 애니메이션과 커스터마이즈를 제공합니다.
/// - **특징**: 활성 점이 강조되고, 비활성 점은 축소되는 Apple Human Interface Guideline 기반 디자인.
///
/// ## 사용 예시 (SwiftUI)
/// ```swift
/// CarouselPageIndicator(
///     currentIndex: $selectedIndex,
///     itemCount: items.count,
///     activeColor: .orange
/// )
/// ```
public struct CarouselPageIndicator: View {

    // MARK: - 설정값

    private let currentIndex: Int
    private let itemCount: Int
    private let activeColor: Color
    private let inactiveColor: Color
    private let dotSize: CGFloat
    private let activeDotWidth: CGFloat
    private let spacing: CGFloat

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - currentIndex: 현재 활성 인덱스
    ///   - itemCount: 전체 아이템 수
    ///   - activeColor: 활성 점 색상 (기본값: `.orange`)
    ///   - inactiveColor: 비활성 점 색상 (기본값: `.white.opacity(0.4)`)
    ///   - dotSize: 점 기본 크기 (기본값: 8pt)
    ///   - activeDotWidth: 활성 점 너비 (기본값: 24pt — pill 형태)
    ///   - spacing: 점 사이 간격 (기본값: 6pt)
    public init(
        currentIndex: Int,
        itemCount: Int,
        activeColor: Color = .orange,
        inactiveColor: Color = .white.opacity(0.4),
        dotSize: CGFloat = 8,
        activeDotWidth: CGFloat = 24,
        spacing: CGFloat = 6
    ) {
        self.currentIndex = currentIndex
        self.itemCount = itemCount
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.dotSize = dotSize
        self.activeDotWidth = activeDotWidth
        self.spacing = spacing
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<itemCount, id: \.self) { index in
                let isActive = index == currentIndex
                Capsule()
                    .fill(isActive ? activeColor : inactiveColor)
                    .frame(
                        width: isActive ? activeDotWidth : dotSize,
                        height: dotSize
                    )
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7),
                        value: currentIndex
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("페이지 인디케이터")
        .accessibilityValue("\(currentIndex + 1) / \(itemCount)")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Page Indicator") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            CarouselPageIndicator(currentIndex: 0, itemCount: 5)
            CarouselPageIndicator(currentIndex: 2, itemCount: 5, activeColor: .blue)
            CarouselPageIndicator(currentIndex: 4, itemCount: 5, activeColor: .purple)
        }
    }
}
#endif
