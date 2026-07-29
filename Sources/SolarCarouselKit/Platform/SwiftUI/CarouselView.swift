import SwiftUI

// MARK: - SolarCarouselView (통합 진입점)

/// SolarCarouselKit의 통합 SwiftUI 진입점
///
/// ## Quick View
/// - **역할**: `CarouselPreset` 열거형 하나로 6가지 Carousel 스타일을 모두 사용할 수 있는 단일 API.
/// - **특징**: 타입 소거(AnyView)를 내부에서만 사용하고, 외부 API는 제네릭으로 타입 안전성 보장.
/// - **Swift 6**: ViewModel 상태는 `@State`로 View 레이어에서 소유. Actor 격리 안전.
///
/// ## 사용 예시
/// ```swift
/// // Hero Banner
/// SolarCarouselView(style: .heroBanner(), items: banners) { banner in
///     BannerCard(banner: banner)
/// }
///
/// // Cover Flow
/// SolarCarouselView(style: .coverFlow(rotation: 45), items: albums) { album in
///     AlbumArtwork(album: album)
///         .frame(width: 200, height: 200)
/// }
/// ```
public struct SolarCarouselView<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let style: CarouselPreset
    private let items: [Item]
    private let content: (Item) -> Content

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - style: 사용할 Carousel 스타일
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        style: CarouselPreset,
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.style = style
        self.items = items
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        switch style {
        case .heroBanner(let peek, let spacing, let indicator):
            HeroBannerCarousel(
                items: items,
                peekAmount: peek,
                spacing: spacing,
                indicatorStyle: indicator,
                content: content
            )

        case .cardStack(let depth, let indicator):
            CardStackCarousel(
                items: items,
                depth: depth,
                indicatorStyle: indicator,
                content: content
            )

        case .fullPager(let indicator):
            FullPagerCarousel(
                items: items,
                indicatorStyle: indicator,
                content: content
            )

        case .coverFlow(let perspective, let rotation, let indicator):
            CoverFlowCarousel(
                items: items,
                rotation: rotation ?? 40,
                perspective: perspective ?? 0.5,
                indicatorStyle: indicator,
                content: content
            )

        case .spotlightFeed(let parallax, let indicator):
            SpotlightFeedCarousel(
                items: items,
                parallaxStrength: parallax ?? 0.3,
                indicatorStyle: indicator,
                content: content
            )

        case .infiniteLoop(let interval, let indicator):
            InfiniteLoopCarousel(
                items: items,
                interval: interval,
                indicatorStyle: indicator,
                content: content
            )
        }
    }
}
