import UIKit

// MARK: - 햅틱 피드백 유틸리티

/// SolarCarouselKit 내 햅틱 피드백 유틸리티
///
/// ## Quick View
/// - **역할**: 페이지 전환, 루프 경계 도달 등 주요 캐러셀 이벤트에 물리적 피드백을 추가합니다.
/// - **특징**: `@MainActor` 격리로 Swift 6 안전. `hapticsEnabled` 플래그로 전체 제어.
/// - **사용 예시**: `HapticsGenerator.triggerSelection()` — 페이지 변경 시 호출
@MainActor
public struct HapticsGenerator: Sendable {

    /// 페이지 변경 등 선택 변경에 적합한 햅틱 (가장 가벼운 피드백)
    public static func triggerSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// 카드 탭, 중요 전환 등에 적합한 임팩트 햅틱
    ///
    /// - Parameter style: 진동의 강도 (`.light`, `.medium`, `.heavy`, `.soft`, `.rigid`)
    public static func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    /// 루프 경계 도달, 로딩 완료 등에 적합한 알림 햅틱
    ///
    /// - Parameter type: 피드백 유형 (`.success`, `.warning`, `.error`)
    public static func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
