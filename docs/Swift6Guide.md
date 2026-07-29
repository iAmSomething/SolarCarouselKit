# SolarCarouselKit & Swift 6 Strict Concurrency

이 가이드는 SolarCarouselKit이 Swift 6의 데이터 레이스 방지 시스템을 어떻게 준수하는지 설명합니다.

## 1. 캡처 의미론 (Capture Semantics)

기존 SwiftUI의 `scrollTransition` 등에서 종종 발생했던 클로저 내부 외부 변수 캡처 에러를 방지합니다.
```swift
// ❌ 기존 방식 (에러 가능성)
let maxRotation = 45.0
view.scrollTransition { view, phase in
    // maxRotation이 외부 상태에 의존할 수 있음
    view.rotation3DEffect(.degrees(maxRotation), ...) 
}

// ✅ SolarCarouselKit 방식 (안전)
let safeRotation = maxRotation // 명시적 let 복사
view.scrollTransition { view, phase in
    // phase와 상숫값만 캡처. Actor 격리 완벽 통과.
    view.rotation3DEffect(.degrees(safeRotation), ...)
}
```

## 2. UIKit의 @MainActor 격리

UIKit 델리게이트는 종종 비동기 환경에서 데이터 레이스의 원인이 됩니다. SolarCarouselKit은 `SolarCarouselViewController` 전체를 `@MainActor`로 격리하여 델리게이트 콜백이 무조건 메인 스레드에서만 실행되도록 보장합니다.

```swift
@MainActor
public final class SolarCarouselViewController: UIViewController {
    // ...
}
```

## 3. 순수 값 타입 상태 관리

`CarouselState`와 `CarouselConfiguration`은 모두 `Sendable`과 순수 구조체(struct)로 구현되어 있습니다. 스레드 경계를 넘나들어도 값이 복사되므로, 여러 뷰나 태스크에서 참조하더라도 데이터 무결성이 보장됩니다.
