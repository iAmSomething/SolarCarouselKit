import SwiftUI

// MARK: - Card Stack Carousel

/// Netflix / 틴더 스타일의 3D 깊이감 카드 덱 Carousel
///
/// ## Quick View
/// - **특징**: 스크롤 중 비활성 카드가 scale + offset으로 원근감 있게 물러나며 깊이(Depth)를 표현합니다.
///   중앙 카드는 항상 최상위에 강조됩니다.
/// - **성능**: GPU 최적화. `scrollTransition`이 Core Animation 레이어에서 직접 동작.
/// - **Swift 6**: 외부 상태 캡처 없는 순수 `phase` 기반 transition.
///
/// ## SwiftUI 사용 예시
/// ```swift
/// CardStackCarousel(items: recommendations, depth: 0.85) { item in
///     RecommendationCard(item: item)
///         .frame(width: 300, height: 400)
/// }
/// ```
public struct CardStackCarousel<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let items: [Item]
    private let depth: CGFloat
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let hapticsEnabled: Bool
    private let indicatorStyle: CarouselIndicatorStyle
    private let content: (Item) -> Content

    @State private var selectedIndex: Int = 0

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - depth: 비활성 카드의 최소 scale 비율. 낮을수록 입체감 증가 (기본값: 0.85)
    ///   - spacing: 카드 사이 간격 (기본값: 전역 설정)
    ///   - cornerRadius: 카드 모서리 반경 (기본값: 전역 설정)
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: false)
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        items: [Item],
        depth: CGFloat? = nil,
        spacing: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        hapticsEnabled: Bool = false,
        indicatorStyle: CarouselIndicatorStyle = .none,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.depth = max(0.5, min(1.0, depth ?? 0.85))
        self.spacing = spacing ?? CarouselKit.configuration.defaultSpacing
        self.cornerRadius = cornerRadius ?? CarouselKit.configuration.defaultCornerRadius
        self.hapticsEnabled = hapticsEnabled
        self.indicatorStyle = indicatorStyle
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        let minDepth = depth // 지역 let으로 캡처 안전성 보장 (Swift 6)

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    content(item)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        // Swift 6 Safe: phase와 minDepth(let 캡처)만 사용
                        .scrollTransition { view, phase in
                            let scale: CGFloat = phase.isIdentity ? 1.0 : minDepth
                            let opacity: Double = phase.isIdentity ? 1.0 : 0.55
                            let yOffset: CGFloat = phase.isIdentity ? 0 : 12

                            return view
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .offset(y: yOffset)
                        }
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 40, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: Binding(get: { selectedIndex }, set: { if let v = $0 { selectedIndex = v } }))
        .onChange(of: selectedIndex) { _, _ in
            if hapticsEnabled {
                HapticsGenerator.triggerSelection()
            }
        }
        .overlay(alignment: .bottom) {
            if items.count > 1 {
                CarouselIndicatorView(
                    style: indicatorStyle,
                    currentIndex: selectedIndex,
                    itemCount: items.count
                )
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct PreviewCard: Identifiable, Sendable {
    let id: Int
    let color: Color
    let emoji: String
}

#Preview("Card Stack Carousel") {
    let cards: [PreviewCard] = [
        PreviewCard(id: 0, color: Color(red: 0.95, green: 0.35, blue: 0.2), emoji: "🔥"),
        PreviewCard(id: 1, color: Color(red: 0.2, green: 0.6, blue: 0.95), emoji: "💧"),
        PreviewCard(id: 2, color: Color(red: 0.5, green: 0.9, blue: 0.4), emoji: "🌿"),
        PreviewCard(id: 3, color: Color(red: 0.9, green: 0.7, blue: 0.1), emoji: "⭐"),
    ]

    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea()
        CardStackCarousel(items: cards) { card in
            card.color
                .overlay(
                    Text(card.emoji)
                        .font(.system(size: 80))
                )
                .frame(width: 280, height: 380)
        }
    }
}
#endif
