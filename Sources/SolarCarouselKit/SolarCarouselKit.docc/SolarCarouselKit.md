# ``SolarCarouselKit``

SwiftUI와 UIKit 앱에 부드럽고 직관적인 6가지 3D 및 2D 캐러셀 UI를 손쉽게 추가할 수 있는 프레임워크입니다.

## Overview

SolarCarouselKit은 iOS 17+의 `scrollTransition` API를 활용하여 메인 스레드 부하 없이 GPU 렌더 서버에서 부드러운 스크롤 애니메이션을 제공합니다. `CarouselPreset`을 통해 6가지 실무형 프리셋(Hero Banner, Full Pager, Cover Flow, Card Stack, Spotlight Feed, Infinite Loop)을 지원하며, 인디케이터 커스텀 등 극대화된 확장성을 제공합니다.

### 빠른 시작 가이드
단 한 줄의 뷰 선언으로 캐러셀을 완성하세요.

```swift
SolarCarouselView(style: .heroBanner(), items: banners) { item in 
    MyCardView(item)
}
```

## Topics

### 🌟 뷰(View) 및 통합
- ``SolarCarouselView``
- ``SolarCarouselViewController``

### ⚙️ 설정 및 프리셋
- ``CarouselPreset``
- ``CarouselIndicatorStyle``
- ``CarouselKit``
- ``CarouselConfiguration``
- ``CarouselPerformanceProfile``

### 🧩 뷰 빌더(View Builder) 및 확장
- ``CarouselPageIndicator``
