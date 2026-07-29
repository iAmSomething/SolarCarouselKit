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
https://github.com/iAmSomething/SolarCarouselKit.git
```

---

## 💻 빠른 시작 (Quick Start)

**SwiftUI 환경:**
```swift
import SwiftUI
import SolarCarouselKit
// import Kingfisher // KFImage 등을 자유롭게 사용할 수 있습니다.

// 1. 모델은 Identifiable을 준수해야 합니다.
struct Banner: Identifiable, Sendable {
    let id = UUID()
    let imageUrl: String
}

struct ContentView: View {
    let banners = [
        Banner(imageUrl: "https://.../img1.png"),
        Banner(imageUrl: "https://.../img2.png")
    ]

    var body: some View {
        SolarCarouselView(
            style: .heroBanner(peekAmount: 30),
            items: banners
        ) { banner in 
            // 2. 클로저 내부는 @ViewBuilder이므로 어떠한 View 타입이든 반환할 수 있습니다.
            // Image, AsyncImage, KFImage 등 제약이 없습니다!
            AsyncImage(url: URL(string: banner.imageUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 250)
    }
}
```

**UIKit 환경 (Modern Closure-based Delegate):**
UIKit 환경에서는 기존의 무거운 `Delegate` 프로토콜 패턴 대신, Swift의 모던한 클로저(Closure) 방식을 사용하여 이벤트를 처리합니다.

```swift
import UIKit
import SolarCarouselKit

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 초기화 및 스타일 지정
        let carousel = SolarCarouselViewController(style: .cardStack())
        
        // 2. 콜렉션 뷰 셀 등록 및 DataSource 연결
        carousel.register(MyCustomCell.self, forCellWithReuseIdentifier: "cell")
        carousel.setDataSource(self) 
        
        // 3. Delegate 함수들을 대체하는 모던 클로저 이벤트
        carousel.onPageChange = { [weak self] pageIndex in
            print("페이지가 \(pageIndex)로 변경되었습니다.")
        }
        
        carousel.onItemTap = { [weak self] tappedIndex in
            print("\(tappedIndex)번째 카드가 터치되었습니다!")
            // 예: self?.navigationController?.pushViewController(...)
        }
        
        // 4. ViewController 뷰 계층에 추가
        addChild(carousel)
        view.addSubview(carousel.view)
        carousel.didMove(toParent: self)
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

## 🔥 특수 케이스 핸들링 (Advanced Usage)

실무에서 자주 마주치는 복잡하고 까다로운 기획 요구사항들도 `SolarCarouselKit`의 순수 SwiftUI 기반 아키텍처 덕분에 손쉽게 해결할 수 있습니다.

### 1. 복합 터치 이벤트 제어 (카드 터치 vs 내부 버튼 터치)
"카드를 누르면 상세 페이지로 가고, 카드 우측 상단의 하트 버튼을 누르면 찜하기가 되어야 해요."
SolarCarouselKit은 터치 이벤트를 강제로 가로채지 않으므로, SwiftUI의 네이티브 제스처 계층이 완벽히 유지됩니다.

```swift
SolarCarouselView(style: .cardStack(), items: products) { product in
    ZStack(alignment: .topTrailing) {
        // 1. 카드 본체 (상세 페이지 이동)
        Image(product.imageUrl)
            .resizable()
            .onTapGesture {
                print("\(product.name) 상세 페이지로 이동")
            }
        
        // 2. 카드 내부 독립적인 버튼 (찜하기)
        Button {
            print("찜하기 추가됨!")
        } label: {
            Image(systemName: "heart.fill")
                .padding()
                .background(.ultraThinMaterial, in: Circle())
        }
        .padding(12)
    }
}
```

### 2. 동적 데이터 추가 (Pagination / 무한 스크롤 연동)
"사용자가 마지막 카드에 도달하면 서버에서 다음 페이지 데이터를 불러와서 캐러셀에 추가해 주세요."
`items` 배열은 SwiftUI 상태(State)와 완벽히 연동되므로, 배열에 새 데이터를 `append` 하기만 하면 부드러운 애니메이션과 함께 캐러셀이 확장됩니다.

```swift
SolarCarouselView(style: .heroBanner(), items: viewModel.items) { item in
    CardView(item: item)
        .onAppear {
            // 마지막 아이템이 화면에 나타날 때 다음 데이터 Fetch
            if item.id == viewModel.items.last?.id {
                viewModel.fetchNextPage()
            }
        }
}
```

### 3. 네비게이션 및 시트(Sheet) 띄우기 연동
각 카드 내부에서 `NavigationLink`를 바로 감싸거나, `.sheet` 모디파이어를 연결해도 상위 스크롤 뷰와 충돌 없이 완벽하게 동작합니다.

```swift
SolarCarouselView(style: .coverFlow(), items: albums) { album in
    NavigationLink(destination: AlbumDetailView(album: album)) {
        Image(album.coverImage)
            .resizable()
            // ...
    }
    .buttonStyle(.plain) // 네비게이션 터치 애니메이션 방지
}
```

---

## ⚙️ 글로벌 환경 설정 (Global Configuration)

앱 실행 초기(`AppDelegate` 또는 `@main`)에 킷의 전역 디자인 시스템을 설정할 수 있습니다.

```swift
CarouselKit.configuration.accentColor = .systemBlue
CarouselKit.configuration.defaultSpacing = 16
CarouselKit.configuration.defaultCornerRadius = 24
CarouselKit.configuration.defaultHapticsEnabled = true
```
