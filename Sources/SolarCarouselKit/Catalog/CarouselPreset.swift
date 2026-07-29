import SwiftUI

// MARK: - 캐러셀 Preset Enum

/// SolarCarouselKit이 제공하는 모든 내장 Carousel Preset
///
/// ## Quick View
/// - **역할**: `View+CarouselKit` extension의 `.carouselKit(style:)` API에서 Preset 스타일을 선택하는 열거형입니다.
/// - **특징**: `Sendable` + `Hashable`. 연관값을 통해 각 Preset의 파라미터를 커스터마이즈할 수 있습니다.
///
/// ## 사용 예시
/// ```swift
/// SolarCarouselView(style: .heroBanner(peekAmount: 40), items: banners) { item in
///     BannerCard(item: item)
/// }
/// ```
public enum CarouselPreset: Sendable, Hashable {

    // MARK: - Banner

    /// **Hero Banner** — 앱스토어, 쇼핑몰 메인 배너 스타일
    ///
    /// 양옆에 다음 카드가 일부 보이는(peek) 효과와 함께 카드가 중앙에 스냅됩니다.
    /// - Parameter peekAmount: 양옆에 보이는 인접 카드의 크기 (기본값: 전역 설정)
    /// - Parameter spacing: 카드 사이 간격 (기본값: 전역 설정)
    /// - Parameter indicatorStyle: 페이지 인디케이터 스타일 (기본값: .dots())
    case heroBanner(peekAmount: CGFloat? = nil, spacing: CGFloat? = nil, indicatorStyle: CarouselIndicatorStyle = .dots())

    // MARK: - Card

    /// **Card Stack** — Netflix / 틴더 스타일 카드 덱
    ///
    /// 스크롤 중 카드가 원근감 있게 scale/rotate 되어 깊이감을 표현합니다.
    /// - Parameter depth: 비활성 카드의 최소 scale (0.8~1.0, 기본값: 0.85)
    /// - Parameter indicatorStyle: 페이지 인디케이터 스타일 (기본값: .none)
    case cardStack(depth: CGFloat? = nil, indicatorStyle: CarouselIndicatorStyle = .none)

    // MARK: - Pager

    /// **Full Pager** — 온보딩, 이미지 뷰어 스타일
    ///
    /// 화면 전체를 채우는 페이지 기반 캐러셀. 페이지 인디케이터 내장.
    /// - Parameter indicatorStyle: 페이지 인디케이터 스타일 (기본값: .dots())
    case fullPager(indicatorStyle: CarouselIndicatorStyle = .dots())

    // MARK: - 3D

    /// **Cover Flow** — 뮤직 앱 앨범 선택 스타일
    ///
    /// iTunes/Apple Music의 Cover Flow처럼 카드가 3D 원근 회전하며 지나갑니다.
    /// - Parameter perspective: 원근감 강도 (0.1~1.0, 기본값: 0.5)
    /// - Parameter rotation: 비활성 카드의 최대 회전 각도 (기본값: 40도)
    /// - Parameter indicatorStyle: 페이지 인디케이터 스타일 (기본값: .none)
    case coverFlow(perspective: CGFloat? = nil, rotation: Double? = nil, indicatorStyle: CarouselIndicatorStyle = .none)

    // MARK: - Feed

    /// **Spotlight Feed** — 소셜 피드 카드 스타일
    ///
    /// 세로 스크롤 피드에서 각 카드가 뷰포트 중앙으로 진입할 때 강조됩니다.
    /// - Parameter parallaxStrength: 배경 패럴랙스 강도 (0.0~1.0, 기본값: 0.3)
    /// - Parameter indicatorStyle: 페이지 인디케이터 스타일 (기본값: .none)
    case spotlightFeed(parallaxStrength: CGFloat? = nil, indicatorStyle: CarouselIndicatorStyle = .none)

    // MARK: - Loop

    /// **Infinite Loop** — 뉴스 티커, 자동 롤링 배너 스타일
    ///
    /// 마지막 아이템 이후 자동으로 첫 아이템으로 돌아가는 무한 루프 캐러셀.
    /// - Parameter interval: 자동 전환 간격 (초, 기본값: 3.0)
    /// - Parameter indicatorStyle: 페이지 인디케이터 스타일 (기본값: .none)
    case infiniteLoop(interval: TimeInterval = 3.0, indicatorStyle: CarouselIndicatorStyle = .none)
}

// MARK: - Preset 기본 메타데이터

extension CarouselPreset {

    /// Preset의 고유 식별자
    public var id: String {
        switch self {
        case .heroBanner:    return "hero_banner"
        case .cardStack:     return "card_stack"
        case .fullPager:     return "full_pager"
        case .coverFlow:     return "cover_flow"
        case .spotlightFeed: return "spotlight_feed"
        case .infiniteLoop:  return "infinite_loop"
        }
    }

    /// 표시 이름
    public var displayName: String {
        switch self {
        case .heroBanner:    return "Hero Banner"
        case .cardStack:     return "Card Stack"
        case .fullPager:     return "Full Pager"
        case .coverFlow:     return "Cover Flow"
        case .spotlightFeed: return "Spotlight Feed"
        case .infiniteLoop:  return "Infinite Loop"
        }
    }

    /// 한국어 설명
    public var description: String {
        switch self {
        case .heroBanner:
            return "앱스토어 스타일의 히어로 배너. 양옆에 다음 카드가 살짝 보여 스와이프를 유도합니다."
        case .cardStack:
            return "Netflix / 틴더 스타일의 카드 덱. 스크롤 중 3D 원근감으로 깊이를 표현합니다."
        case .fullPager:
            return "화면 전체를 채우는 풀스크린 페이저. 온보딩이나 이미지 뷰어에 최적입니다."
        case .coverFlow:
            return "Apple Music의 Cover Flow처럼 카드가 3D로 회전하며 넘어갑니다."
        case .spotlightFeed:
            return "소셜 피드 스타일. 뷰포트 중앙의 카드를 강조하고 패럴랙스 효과를 제공합니다."
        case .infiniteLoop:
            return "자동 무한 루프 롤링 배너. 뉴스 티커나 광고 배너에 적합합니다."
        }
    }

    /// 성능 프로파일
    public var performance: CarouselPerformanceProfile {
        switch self {
        case .heroBanner:
            return CarouselPerformanceProfile(
                classType: .gpuOptimized,
                estimatedMemoryFootprint: "Low (<2KB/item)",
                supportsLazyLoading: true
            )
        case .cardStack:
            return CarouselPerformanceProfile(
                classType: .gpuOptimized,
                estimatedMemoryFootprint: "Low (<3KB/item)",
                supportsLazyLoading: true
            )
        case .fullPager:
            return CarouselPerformanceProfile(
                classType: .gpuOptimized,
                estimatedMemoryFootprint: "Low (<2KB/item)",
                supportsLazyLoading: true
            )
        case .coverFlow:
            return CarouselPerformanceProfile(
                classType: .offscreenRisk,
                estimatedMemoryFootprint: "Medium (<8KB/item)",
                needsRasterization: true,
                supportsLazyLoading: true
            )
        case .spotlightFeed:
            return CarouselPerformanceProfile(
                classType: .linearPerItems,
                estimatedMemoryFootprint: "Low (<2KB/item)",
                supportsLazyLoading: true
            )
        case .infiniteLoop:
            return CarouselPerformanceProfile(
                classType: .cpuBound,
                estimatedMemoryFootprint: "Low (<4KB total)",
                supportsLazyLoading: false
            )
        }
    }
}
