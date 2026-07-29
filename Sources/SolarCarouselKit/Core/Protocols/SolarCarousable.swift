import SwiftUI
import UIKit

// MARK: - 지원 플랫폼

/// 각 Preset이 지원하는 플랫폼 정보
///
/// ## Quick View
/// - **역할**: SwiftUI 전용, UIKit 전용, 혹은 양쪽 모두를 지원하는지 나타냅니다.
public struct SupportedPlatforms: OptionSet, Sendable {
    public let rawValue: Int
    public static let swiftUI = SupportedPlatforms(rawValue: 1 << 0)
    public static let uiKit   = SupportedPlatforms(rawValue: 1 << 1)
    public static let both: SupportedPlatforms = [.swiftUI, .uiKit]

    public init(rawValue: Int) { self.rawValue = rawValue }
}

// MARK: - Core Protocol

/// SolarCarouselKit의 모든 Carousel Preset이 준수하는 핵심 프로토콜
///
/// ## Quick View
/// - **목적**: 하나의 통일된 인터페이스로 SwiftUI와 UIKit 양쪽에서 캐러셀을 구동합니다.
/// - **특징**: Swift 6 Strict Concurrency 완전 대응. `Sendable` 채택 필수.
/// - **확장**: 10줄 미만의 코드로 커스텀 Carousel Preset을 추가할 수 있습니다.
///
/// ## 사용 예시
/// ```swift
/// struct MyCustomCarousel: SolarCarousable {
///     typealias ItemType = MyData
///     // 요구사항 구현...
/// }
/// ```
public protocol SolarCarousable: Sendable {
    /// 이 Preset의 데이터 타입. `Sendable`과 `Identifiable`을 준수해야 합니다.
    associatedtype ItemType: Sendable & Identifiable

    /// Preset의 고유 식별자 (예: "hero_banner")
    var id: String { get }

    /// 사용자에게 표시되는 이름 (예: "Hero Banner")
    var displayName: String { get }

    /// Preset의 기능과 특징을 설명하는 한국어 설명
    var description: String { get }

    /// 성능 프로파일 메타데이터
    var performance: CarouselPerformanceProfile { get }

    /// 지원하는 플랫폼 (SwiftUI, UIKit, 또는 둘 다)
    var supportedPlatforms: SupportedPlatforms { get }

    /// SwiftUI용 캐러셀 뷰를 생성합니다.
    ///
    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - selection: 현재 선택된 인덱스에 대한 바인딩
    ///   - content: 각 아이템에 대한 뷰를 반환하는 ViewBuilder
    /// - Returns: 완성된 캐러셀 뷰 (타입 소거)
    @MainActor
    func makeCarouselView<Content: View>(
        items: [ItemType],
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (ItemType) -> Content
    ) -> AnyView
}
