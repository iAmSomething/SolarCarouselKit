import Foundation

// MARK: - 캐러셀 상태

/// 캐러셀의 런타임 상태를 캡슐화하는 순수 값 타입
///
/// ## Quick View
/// - **역할**: 현재 페이지 인덱스, 전체 아이템 수, 루프 여부 등의 상태를 값 타입으로 관리합니다.
/// - **특징**: `Sendable` 준수 구조체이므로 Swift 6에서 데이터 레이스 없이 안전하게 사용 가능.
/// - **사용처**: `CarouselViewModel`이 내부 상태로 보유하며, 뷰는 이를 읽기 전용으로 참조합니다.
public struct CarouselState: Sendable, Equatable {

    // MARK: - 프로퍼티

    /// 현재 표시 중인 아이템의 인덱스 (0-based)
    public private(set) var currentIndex: Int

    /// 전체 아이템 수
    public let itemCount: Int

    /// 마지막 아이템에서 첫 아이템으로 순환 여부
    public let isLooping: Bool

    // MARK: - 이니셜라이저

    public init(
        currentIndex: Int = 0,
        itemCount: Int,
        isLooping: Bool = false
    ) {
        self.currentIndex = max(0, min(currentIndex, max(0, itemCount - 1)))
        self.itemCount = itemCount
        self.isLooping = isLooping
    }

    // MARK: - 상태 계산

    /// 이전 인덱스를 반환합니다. 루프 없이 첫 아이템이면 nil 반환.
    public var previousIndex: Int? {
        if currentIndex > 0 {
            return currentIndex - 1
        } else if isLooping && itemCount > 1 {
            return itemCount - 1
        }
        return nil
    }

    /// 다음 인덱스를 반환합니다. 루프 없이 마지막 아이템이면 nil 반환.
    public var nextIndex: Int? {
        if currentIndex < itemCount - 1 {
            return currentIndex + 1
        } else if isLooping && itemCount > 1 {
            return 0
        }
        return nil
    }

    /// 첫 번째 아이템인지 여부
    public var isFirst: Bool { currentIndex == 0 }

    /// 마지막 아이템인지 여부
    public var isLast: Bool { currentIndex == itemCount - 1 }

    /// 진행률 (0.0 ~ 1.0)
    public var progress: Double {
        guard itemCount > 1 else { return 0 }
        return Double(currentIndex) / Double(itemCount - 1)
    }

    // MARK: - 상태 변이

    /// 다음 페이지로 이동한 새로운 상태를 반환합니다.
    public func advancing() -> CarouselState {
        guard let next = nextIndex else { return self }
        return CarouselState(currentIndex: next, itemCount: itemCount, isLooping: isLooping)
    }

    /// 이전 페이지로 이동한 새로운 상태를 반환합니다.
    public func retreating() -> CarouselState {
        guard let prev = previousIndex else { return self }
        return CarouselState(currentIndex: prev, itemCount: itemCount, isLooping: isLooping)
    }

    /// 특정 인덱스로 이동한 새로운 상태를 반환합니다.
    public func movingTo(index: Int) -> CarouselState {
        guard index >= 0 && index < itemCount else { return self }
        return CarouselState(currentIndex: index, itemCount: itemCount, isLooping: isLooping)
    }
}
