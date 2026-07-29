import SwiftUI

// MARK: - 캐러셀 전역 설정

/// SolarCarouselKit의 전역 동작을 제어하는 설정 값 타입
///
/// ## Quick View
/// - **역할**: 자동 스크롤 간격, 햅틱 기본값, 페이지 인디케이터 스타일 등을 앱 수준에서 한번에 지정합니다.
/// - **특징**: `Sendable` + `Equatable` 값 타입. 불변(immutable) 구성으로 데이터 레이스 없음.
///
/// ## 사용 예시
/// ```swift
/// CarouselKit.configure {
///     $0.defaultAutoScrollInterval = 4.0
///     $0.defaultHapticsEnabled = true
///     $0.accentColor = .orange
/// }
/// ```
public struct CarouselConfiguration: Sendable, Equatable {

    // MARK: - 자동 스크롤 설정

    /// 자동 스크롤 간격 (초). nil이면 자동 스크롤 비활성화.
    public var defaultAutoScrollInterval: TimeInterval?

    /// 자동 스크롤 시 루프 여부 기본값
    public var defaultAutoScrollLoops: Bool

    // MARK: - 시각 설정

    /// Kit 전체에 적용되는 강조 색상 (페이지 인디케이터 등)
    public var accentColor: Color

    /// 카드 간격 기본값 (pt)
    public var defaultSpacing: CGFloat

    /// Peek 영역 크기 기본값 (pt) — 인접 카드가 보이는 양
    public var defaultPeekAmount: CGFloat

    /// 카드 모서리 반경 기본값 (pt)
    public var defaultCornerRadius: CGFloat

    // MARK: - 햅틱 설정

    /// 페이지 변경 시 햅틱 피드백 기본 활성화 여부
    public var defaultHapticsEnabled: Bool

    // MARK: - 기본값

    public static let `default` = CarouselConfiguration()

    // MARK: - 이니셜라이저

    public init(
        defaultAutoScrollInterval: TimeInterval? = nil,
        defaultAutoScrollLoops: Bool = true,
        accentColor: Color = .orange,
        defaultSpacing: CGFloat = 12,
        defaultPeekAmount: CGFloat = 32,
        defaultCornerRadius: CGFloat = 16,
        defaultHapticsEnabled: Bool = false
    ) {
        self.defaultAutoScrollInterval = defaultAutoScrollInterval
        self.defaultAutoScrollLoops = defaultAutoScrollLoops
        self.accentColor = accentColor
        self.defaultSpacing = defaultSpacing
        self.defaultPeekAmount = defaultPeekAmount
        self.defaultCornerRadius = defaultCornerRadius
        self.defaultHapticsEnabled = defaultHapticsEnabled
    }
}

// MARK: - 전역 네임스페이스

/// SolarCarouselKit의 전역 설정 진입점
///
/// ## Quick View
/// - **역할**: 앱 시작 시 전역 CarouselConfiguration을 지정합니다.
/// - **Swift 6**: `@MainActor` 격리로 데이터 레이스 완전 차단.
@MainActor
public final class CarouselKit: Sendable {

    // MARK: - 싱글턴

    public static let shared = CarouselKit()

    private init() {}

    // MARK: - 전역 설정

    nonisolated(unsafe) private static var _configuration = CarouselConfiguration.default

    public static var configuration: CarouselConfiguration {
        get { _configuration }
        set { _configuration = newValue }
    }

    /// 빌더 패턴으로 전역 설정을 업데이트합니다.
    ///
    /// ## 사용 예시
    /// ```swift
    /// CarouselKit.configure {
    ///     $0.defaultHapticsEnabled = true
    ///     $0.accentColor = .orange
    /// }
    /// ```
    public static func configure(_ block: (inout CarouselConfiguration) -> Void) {
        block(&_configuration)
    }
}
