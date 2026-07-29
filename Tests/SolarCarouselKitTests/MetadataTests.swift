import Testing
@testable import SolarCarouselKit

// MARK: - 메타데이터 테스트

/// 각 Preset의 정적 메타데이터가 올바르게 정의되어 있는지 검증합니다.
/// UI 렌더링 없이 순수 값 타입만 테스트합니다.
@Suite("CarouselPreset Metadata Tests")
struct MetadataTests {

    // MARK: - 전체 Preset 수 검증

    @Test("카탈로그에 6개의 Preset이 등록되어 있어야 함")
    func presetCount() {
        #expect(CarouselCatalog.allPresets.count == 6)
    }

    // MARK: - ID 고유성 검증

    @Test("모든 Preset ID는 고유해야 함")
    func presetIDsAreUnique() {
        let ids = CarouselCatalog.allPresets.map { $0.id }
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count, "중복 ID 발견: \(ids)")
    }

    // MARK: - 개별 Preset 메타데이터 검증

    @Test("HeroBanner Preset 메타데이터")
    func heroBannerMetadata() {
        let preset = CarouselPreset.heroBanner()
        #expect(preset.id == "hero_banner")
        #expect(preset.displayName == "Hero Banner")
        #expect(!preset.description.isEmpty)
        #expect(preset.performance.supportsLazyLoading == true)
        #expect(preset.performance.classType == .gpuOptimized)
    }

    @Test("CardStack Preset 메타데이터")
    func cardStackMetadata() {
        let preset = CarouselPreset.cardStack()
        #expect(preset.id == "card_stack")
        #expect(preset.performance.supportsLazyLoading == true)
    }

    @Test("FullPager Preset 메타데이터")
    func fullPagerMetadata() {
        let preset = CarouselPreset.fullPager()
        #expect(preset.id == "full_pager")
        #expect(preset.performance.supportsLazyLoading == true)
    }

    @Test("CoverFlow Preset 성능 경고")
    func coverFlowPerformanceWarning() {
        let preset = CarouselPreset.coverFlow()
        #expect(preset.performance.classType == .offscreenRisk)
        #expect(preset.performance.needsRasterization == true)
        #expect(preset.performance.safetyWarning != nil, "CoverFlow는 성능 경고가 있어야 함")
    }

    @Test("SpotlightFeed Preset 메타데이터")
    func spotlightFeedMetadata() {
        let preset = CarouselPreset.spotlightFeed()
        #expect(preset.id == "spotlight_feed")
        #expect(preset.performance.classType == .linearPerItems)
    }

    @Test("InfiniteLoop Preset은 Lazy Loading 미지원")
    func infiniteLoopLazyLoading() {
        let preset = CarouselPreset.infiniteLoop()
        #expect(preset.performance.supportsLazyLoading == false,
                "InfiniteLoop는 아이템 전체 복제가 필요하므로 Lazy Loading 불가")
    }

    // MARK: - 실무 사용 사례 검증

    @Test("모든 Preset은 1개 이상의 실무 사용 사례를 가짐")
    func allPresetsHaveUseCases() {
        for preset in CarouselCatalog.allPresets {
            let useCases = CarouselCatalog.useCases(for: preset)
            #expect(!useCases.isEmpty, "\(preset.displayName)의 사용 사례가 비어있음")
        }
    }

    // MARK: - ID 조회 검증

    @Test("ID로 Preset 조회 성공")
    func presetLookupByID() {
        #expect(CarouselCatalog.preset(forID: "hero_banner") != nil)
        #expect(CarouselCatalog.preset(forID: "cover_flow") != nil)
        #expect(CarouselCatalog.preset(forID: "nonexistent_id") == nil)
    }

    @Test("Lazy Loading 지원 Preset 필터링")
    func lazyLoadingFilter() {
        let lazyPresets = CarouselCatalog.presets(supportsLazyLoading: true)
        let eagerPresets = CarouselCatalog.presets(supportsLazyLoading: false)
        #expect(lazyPresets.count + eagerPresets.count == CarouselCatalog.allPresets.count)
        // InfiniteLoop만 eager (복제 배열 필요)
        #expect(eagerPresets.count == 1)
        #expect(eagerPresets.first?.id == "infinite_loop")
    }
}
