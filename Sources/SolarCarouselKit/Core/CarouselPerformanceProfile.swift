import Foundation

// MARK: - 성능 프로파일

/// Carousel Preset의 성능 특성을 기술하는 값 타입
///
/// ## Quick View
/// - **역할**: AI 에이전트(MCP)가 어떤 Preset을 추천할지 판단하거나, 개발자가 성능 트레이드오프를 이해하는 데 사용됩니다.
/// - **특징**: `Sendable` 완전 준수 값 타입.
public struct CarouselPerformanceProfile: Sendable, Equatable {

    // MARK: - 복잡도 분류

    public enum ComplexityClass: String, Sendable, CaseIterable {
        /// Metal/Core Animation GPU 가속. 오프스크린 렌더링 없음.
        case gpuOptimized = "O(1)-GPU"
        /// CPU에서 연산 후 GPU로 전달. 소규모 목록에 적합.
        case cpuBound = "O(1)-CPU"
        /// 아이템 수에 선형 비례. `LazyHStack`으로 완화.
        case linearPerItems = "O(n)-Items"
        /// 매 프레임 layout 재계산 발생. 주의 필요.
        case layoutInvalidating = "O(n)-Layout"
        /// 오프스크린 렌더링 발생 가능. 인스턴스 수 제한 권장.
        case offscreenRisk = "O(1)-Offscreen"
    }

    // MARK: - 프로퍼티

    /// 복잡도 분류
    public let classType: ComplexityClass

    /// 예상 메모리 사용량 (예: "Low (<2KB/item)")
    public let estimatedMemoryFootprint: String

    /// Main Thread 블로킹 여부
    public let mainThreadBlocking: Bool

    /// 래스터라이제이션(오프스크린 렌더링) 필요 여부
    public let needsRasterization: Bool

    /// 동시에 인스턴스를 안전하게 사용할 수 있는 최대 개수
    public let recommendedMaxInstances: Int

    /// 메모리 누수 잠재 위험 여부
    public let potentialLeakRisk: Bool

    /// 아이템 지연 로딩(Lazy Loading) 지원 여부
    public let supportsLazyLoading: Bool

    // MARK: - 이니셜라이저

    public init(
        classType: ComplexityClass,
        estimatedMemoryFootprint: String = "Low (<2KB/item)",
        mainThreadBlocking: Bool = false,
        needsRasterization: Bool = false,
        recommendedMaxInstances: Int = 1,
        potentialLeakRisk: Bool = false,
        supportsLazyLoading: Bool = true
    ) {
        self.classType = classType
        self.estimatedMemoryFootprint = estimatedMemoryFootprint
        self.mainThreadBlocking = mainThreadBlocking
        self.needsRasterization = needsRasterization
        self.recommendedMaxInstances = recommendedMaxInstances
        self.potentialLeakRisk = potentialLeakRisk
        self.supportsLazyLoading = supportsLazyLoading
    }

    // MARK: - 계산 프로퍼티

    /// 사람이 읽기 쉬운 성능 등급 레이블
    public var performanceLabel: String {
        switch classType {
        case .gpuOptimized:     return "🚀 GPU Optimized"
        case .cpuBound:         return "⚡ CPU Bound"
        case .linearPerItems:   return "⚠️ Linear Per Items"
        case .layoutInvalidating: return "🛑 Layout Invalidating"
        case .offscreenRisk:    return "🔥 Offscreen Risk"
        }
    }

    /// 성능 주의사항이 있으면 한국어 경고 문자열 반환
    public var safetyWarning: String? {
        if needsRasterization {
            return "오프스크린 렌더링(래스터라이제이션) 발생. 많은 아이템에 동시 적용 시 GPU 메모리 주의."
        }
        switch classType {
        case .offscreenRisk where recommendedMaxInstances < 3:
            return "오프스크린 렌더링 위험. 화면당 1개 인스턴스만 사용하세요."
        case .layoutInvalidating:
            return "매 프레임 레이아웃 무효화. 고속 스크롤 뷰 내부에서 중첩 사용 비추천."
        case .linearPerItems:
            return "아이템 수에 비례한 연산 비용. LazyHStack 사용이 필수입니다."
        default:
            return nil
        }
    }
}
