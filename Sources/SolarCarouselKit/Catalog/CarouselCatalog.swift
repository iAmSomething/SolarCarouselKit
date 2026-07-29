import Foundation

// MARK: - 캐러셀 카탈로그

/// 모든 내장 Carousel Preset의 메타데이터를 등록하고 조회하는 레지스트리
///
/// ## Quick View
/// - **역할**: MCP 서버가 `list_carousel_presets`를 호출할 때 메타데이터를 반환하는 중앙 저장소입니다.
/// - **특징**: 전체 전역 상태 없음. 순수 함수형 조회만 제공.
///
/// ## 사용 예시 (MCP 서버 연동)
/// ```swift
/// let all = CarouselCatalog.allPresets
/// let useCases = CarouselCatalog.useCases(for: .heroBanner())
/// ```
public enum CarouselCatalog {

    // MARK: - 전체 Preset 목록

    /// 사용 가능한 모든 Carousel Preset
    public static let allPresets: [CarouselPreset] = [
        .heroBanner(),
        .cardStack(),
        .fullPager(),
        .coverFlow(),
        .spotlightFeed(),
        .infiniteLoop()
    ]

    // MARK: - 실무 사용 사례

    /// 특정 Preset의 실무 사용 사례를 반환합니다.
    public static func useCases(for preset: CarouselPreset) -> [String] {
        switch preset {
        case .heroBanner:
            return [
                "앱스토어 피처드 앱 배너",
                "쇼핑몰 메인 프로모션 배너",
                "뉴스 앱 헤드라인 카드",
                "음식 배달 앱 식당 추천 슬라이더"
            ]
        case .cardStack:
            return [
                "틴더 스타일 추천 매칭 카드",
                "Netflix 추천 콘텐츠 카드 덱",
                "플래시카드 / 학습 앱 카드",
                "여행 앱 목적지 추천 카드"
            ]
        case .fullPager:
            return [
                "앱 온보딩 스크린",
                "이미지 / 사진 뷰어",
                "스토리 기능 (인스타그램 스타일)",
                "튜토리얼 안내 슬라이드"
            ]
        case .coverFlow:
            return [
                "뮤직 앱 앨범 아트워크 선택",
                "갤러리 앱 사진 브라우저",
                "게임 아이템 선택 UI",
                "북 앱 표지 선택"
            ]
        case .spotlightFeed:
            return [
                "소셜 미디어 피드 카드",
                "리뷰 / 평가 카드 리스트",
                "레시피 앱 요리 목록",
                "부동산 앱 매물 목록"
            ]
        case .infiniteLoop:
            return [
                "뉴스 헤드라인 자동 롤링 배너",
                "광고 / 프로모션 자동 슬라이드",
                "스포츠 경기 점수 티커",
                "공지사항 자동 순환 배너"
            ]
        }
    }

    // MARK: - 조회 헬퍼

    /// ID로 Preset을 조회합니다.
    public static func preset(forID id: String) -> CarouselPreset? {
        allPresets.first { $0.id == id }
    }

    /// 카테고리(lazy vs eager)로 Preset을 필터링합니다.
    public static func presets(supportsLazyLoading: Bool) -> [CarouselPreset] {
        allPresets.filter { $0.performance.supportsLazyLoading == supportsLazyLoading }
    }
}
