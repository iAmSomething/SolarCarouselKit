# SolarCarouselKit 🎡

**SolarCarouselKit**은 iOS 개발자들이 가장 자주 마주하는 6가지 캐러셀/페이지 뷰 패턴을 SwiftUI와 UIKit 환경에서 단 한 줄의 코드로 구현할 수 있게 해주는 강력한 오픈소스 UI 프레임워크입니다. 

iOS 17+의 `scrollTransition` API를 활용하여 100% GPU 가속 기반의 부드러운 애니메이션을 제공하며, Swift 6의 엄격한 동시성(Strict Concurrency) 규칙을 완벽하게 준수합니다.

## ✨ 주요 기능 (6 Presets)
SolarCarouselKit은 별도의 복잡한 레이아웃 계산 없이 `CarouselPreset` 열거형을 통해 다음 6가지 스타일을 즉시 제공합니다.

1. **Hero Banner** (`.heroBanner`) - 양옆 카드가 살짝 보이는 앱스토어 스타일 배너
2. **Full Pager** (`.fullPager`) - 화면 전체를 채우는 온보딩/이미지 뷰어 스타일
3. **Cover Flow** (`.coverFlow`) - 3D로 카드가 회전하는 뮤직 플레이어 앨범 선택 스타일
4. **Card Stack** (`.cardStack`) - 원근감 있게 카드가 쌓이는 틴더/넷플릭스 스타일
5. **Spotlight Feed** (`.spotlightFeed`) - 뷰포트 중앙 뷰가 강조되는 세로 스크롤 소셜 피드
6. **Infinite Loop** (`.infiniteLoop`) - 자동으로 무한 롤링되는 뉴스 티커 / 광고 배너

---

## 🛠 설치 방법 (Swift Package Manager)

Xcode의 `File > Add Package Dependencies...` 메뉴에서 아래 URL을 입력하여 설치할 수 있습니다.
```text
https://github.com/your-repo/SolarCarouselKit.git
```

---

## 💻 빠른 시작 (Quick Start)

**SwiftUI 환경:**
```swift
import SwiftUI
import SolarCarouselKit

struct ContentView: View {
    let images = ["img1", "img2", "img3"]

    var body: some View {
        SolarCarouselView(
            style: .heroBanner(peekAmount: 30),
            items: images
        ) { imageName in 
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 250)
    }
}
```

**UIKit 환경:**
```swift
import UIKit
import SolarCarouselKit

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let carousel = SolarCarouselViewController(style: .cardStack())
        // Configure Data Source & Add to View...
    }
}
```

---

## 🎨 커스텀 및 확장 가이드 (Extensibility Guide)

패키지를 사용할 때 기획/디자인 요구사항에 맞춰 인디케이터(Page Indicator)를 자유롭게 변경할 수 있도록 설계되었습니다. 

`CarouselIndicatorStyle`을 통해 기본 점, 텍스트(분수), 프로그레스 바를 제공하며, 만약 완전히 새로운 디자인이 필요하다면 **`.custom`** 케이스를 사용하여 `Extension`처럼 본인만의 뷰를 주입할 수 있습니다.

### 1. 내장 스타일 사용하기
```swift
SolarCarouselView(
    style: .fullPager(indicatorStyle: .progressBar(activeColor: .blue, inactiveColor: .gray)),
    items: data
) { item in ... }
```

### 2. `.custom`을 활용한 완전한 커스텀 주입 (의도된 확장점)
만약 기본 제공되는 스타일 외에 독특한 애니메이션이나 커스텀 아이콘을 띄우고 싶다면, `.custom` 클로저를 활용해 패키지의 내부 뼈대를 건드리지 않고도 확장이 가능합니다.

```swift
SolarCarouselView(
    style: .heroBanner(
        indicatorStyle: .custom { currentIndex, totalCount in
            AnyView(
                HStack {
                    Text("🔥 현재 \(currentIndex + 1)번째 배너 보는 중!")
                        .font(.caption.bold())
                }
                .padding()
                .background(.ultraThinMaterial, in: Capsule())
            )
        }
    ),
    items: banners
) { item in 
    // Card View...
}
```

이러한 개방-폐쇄 원칙(OCP) 기반의 설계를 통해, `SolarCarouselKit`은 프레임워크 내부 코드를 수정할 필요 없이 여러분의 앱 디자인 시스템에 완벽하게 녹아듭니다!

---

## ⚙️ 글로벌 환경 설정 (Global Configuration)

앱 실행 초기(`AppDelegate` 또는 `@main`)에 킷의 전역 디자인 시스템을 설정할 수 있습니다.

```swift
CarouselKit.configuration.accentColor = .systemBlue
CarouselKit.configuration.defaultSpacing = 16
CarouselKit.configuration.defaultCornerRadius = 24
CarouselKit.configuration.defaultHapticsEnabled = true
```
