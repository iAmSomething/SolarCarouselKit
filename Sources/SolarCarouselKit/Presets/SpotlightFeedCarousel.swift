import SwiftUI

// MARK: - Spotlight Feed Carousel

/// 소셜 피드 스타일 — 세로 스크롤에서 중앙 카드를 강조하는 Carousel
///
/// ## Quick View
/// - **특징**: `ScrollView(.vertical)` 기반으로, 뷰포트 중앙에 들어온 카드가 스케일/밝기 강조됩니다.
///   배경에 미묘한 패럴랙스(Parallax) 효과를 제공해 깊이감을 표현합니다.
/// - **성능**: `LazyVStack` 기반. 긴 피드 목록도 메모리 효율적.
/// - **Swift 6**: `parallaxStrength`를 `let` 캡처해 `scrollTransition` 내부에서 안전하게 사용.
///
/// ## SwiftUI 사용 예시
/// ```swift
/// SpotlightFeedCarousel(items: posts, parallaxStrength: 0.3) { post in
///     PostCard(post: post)
///         .frame(height: 300)
/// }
/// ```
public struct SpotlightFeedCarousel<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let items: [Item]
    private let parallaxStrength: CGFloat
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let hapticsEnabled: Bool
    private let indicatorStyle: CarouselIndicatorStyle
    private let content: (Item) -> Content

    @State private var selectedIndex: Int = 0

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - parallaxStrength: 배경 패럴랙스 강도 (0.0~1.0, 기본값: 0.3)
    ///   - spacing: 카드 사이 간격 (기본값: 전역 설정)
    ///   - cornerRadius: 카드 모서리 반경 (기본값: 전역 설정)
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: false)
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        items: [Item],
        parallaxStrength: CGFloat = 0.3,
        spacing: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        hapticsEnabled: Bool = false,
        indicatorStyle: CarouselIndicatorStyle = .none,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.parallaxStrength = max(0, min(1.0, parallaxStrength))
        self.spacing = spacing ?? CarouselKit.configuration.defaultSpacing
        self.cornerRadius = cornerRadius ?? CarouselKit.configuration.defaultCornerRadius
        self.hapticsEnabled = hapticsEnabled
        self.indicatorStyle = indicatorStyle
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        let strength = parallaxStrength  // let 캡처 (Swift 6 Safe)

        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: spacing) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    content(item)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        // Swift 6 Safe: strength는 let 캡처, phase는 파라미터
                        .scrollTransition { view, phase in
                            let scale: CGFloat = phase.isIdentity ? 1.0 : 0.94
                            let opacity: Double = phase.isIdentity ? 1.0 : 0.55
                            let blur: CGFloat = phase.isIdentity ? 0 : 1.5
                            // 패럴랙스: 진입/이탈 방향에 따라 수직 오프셋
                            let yOffset: CGFloat = phase.isIdentity ? 0
                                : (phase == .topLeading ? -30 * strength : 30 * strength)

                            return view
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .blur(radius: blur)
                                .offset(y: yOffset)
                        }
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.vertical, 60, for: .scrollContent)
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
private struct FeedPost: Identifiable, Sendable {
    let id: Int
    let color: Color
    let author: String
    let content: String
}

#Preview("Spotlight Feed Carousel") {
    let posts: [FeedPost] = [
        FeedPost(id: 0, color: Color(red: 0.9, green: 0.3, blue: 0.2), author: "@design_kr", content: "Swift 6로 만든 첫 번째 피드 카드 🚀"),
        FeedPost(id: 1, color: Color(red: 0.2, green: 0.5, blue: 0.9), author: "@ios_dev", content: "SolarCarouselKit 개발 중... 너무 재밌다"),
        FeedPost(id: 2, color: Color(red: 0.5, green: 0.8, blue: 0.3), author: "@ux_korea", content: "Spotlight Feed 효과가 소셜 앱에 완벽한 이유"),
        FeedPost(id: 3, color: Color(red: 0.8, green: 0.5, blue: 0.9), author: "@solar_kits", content: "오픈소스 기여자를 모집합니다! ✨"),
    ]

    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.1).ignoresSafeArea()
        SpotlightFeedCarousel(items: posts) { post in
            post.color
                .overlay(
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.author)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white.opacity(0.7))
                        Text(post.content)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(20),
                    alignment: .topLeading
                )
                .frame(height: 260)
        }
        .padding(.horizontal, 20)
    }
}
#endif
