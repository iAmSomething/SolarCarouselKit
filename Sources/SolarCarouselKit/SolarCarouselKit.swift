/// # SolarCarouselKit
///
/// Apple 생태계를 위한 최고급 Carousel View SDK.
/// Swift 6 Strict Concurrency를 완전히 준수하며 SwiftUI와 UIKit을 동시에 지원합니다.
///
/// ## 제공 Preset
/// - **HeroBanner**: 앱스토어 스타일 배너 (peek 효과 + 스냅)
/// - **CardStack**: Netflix / 틴더 스타일 3D 깊이감 카드 덱
/// - **FullPager**: 온보딩 / 이미지 뷰어용 풀스크린 페이저
/// - **CoverFlow**: Apple Music 스타일 3D 회전 캐러셀
/// - **SpotlightFeed**: 소셜 피드 스타일 세로 스크롤 강조 뷰
/// - **InfiniteLoop**: 자동 무한 루프 롤링 배너
///
/// ## 빠른 시작 (SwiftUI)
/// ```swift
/// import SolarCarouselKit
///
/// SolarCarouselView(style: .heroBanner(), items: myItems) { item in
///     MyItemCard(item: item)
/// }
/// ```
///
/// ## 빠른 시작 (UIKit)
/// ```swift
/// import SolarCarouselKit
///
/// let carousel = SolarCarouselViewController(style: .cardStack())
/// carousel.configure(itemCount: myItems.count)
/// carousel.onPageChange = { index in print("Page: \(index)") }
/// ```
///
/// ## 전역 설정
/// ```swift
/// CarouselKit.configure {
///     $0.defaultHapticsEnabled = true
///     $0.accentColor = .orange
///     $0.defaultAutoScrollInterval = 3.0
/// }
/// ```

