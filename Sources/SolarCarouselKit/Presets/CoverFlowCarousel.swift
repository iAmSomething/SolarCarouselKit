import SwiftUI

// MARK: - Cover Flow Carousel

/// Apple Music의 Cover Flow를 재현하는 3D 회전 Carousel
///
/// ## Quick View
/// - **특징**: 스크롤 중 카드가 Y축으로 3D 회전하며 앨범 아트워크 선택 느낌을 구현합니다.
///   `rotation3DEffect` + `scrollTransition` 조합으로 완전 GPU 가속.
/// - **성능 주의**: 오프스크린 렌더링(래스터라이제이션) 발생 가능.
///   카드에 `.drawingGroup()` 적용을 고려하세요.
/// - **Swift 6**: 클로저 내부에서 `phase` 값만 사용. `maxRotation`은 `let` 캡처로 안전.
///
/// ## SwiftUI 사용 예시
/// ```swift
/// CoverFlowCarousel(items: albums, rotation: 45) { album in
///     AsyncImage(url: album.artworkURL) { img in img.resizable() }
///         .frame(width: 200, height: 200)
///         .clipShape(RoundedRectangle(cornerRadius: 12))
/// }
/// ```
public struct CoverFlowCarousel<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let items: [Item]
    private let maxRotation: Double
    private let perspective: CGFloat
    private let spacing: CGFloat
    private let hapticsEnabled: Bool
    private let indicatorStyle: CarouselIndicatorStyle
    private let content: (Item) -> Content

    @State private var selectedIndex: Int = 0

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - rotation: 비활성 카드의 최대 Y축 회전 각도 (기본값: 40도)
    ///   - perspective: 원근감 강도 (0.1~1.0, 기본값: 0.5)
    ///   - spacing: 카드 사이 간격 (기본값: -30, 겹침 효과)
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: false)
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        items: [Item],
        rotation: Double = 40,
        perspective: CGFloat = 0.5,
        spacing: CGFloat = -30,
        hapticsEnabled: Bool = false,
        indicatorStyle: CarouselIndicatorStyle = .none,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.maxRotation = max(0, min(90, rotation))
        self.perspective = max(0.1, min(1.0, perspective))
        self.spacing = spacing
        self.hapticsEnabled = hapticsEnabled
        self.indicatorStyle = indicatorStyle
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        let rot = maxRotation    // let 캡처 (Swift 6 Safe)
        let persp = perspective  // let 캡처 (Swift 6 Safe)

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    content(item)
                        // 오프스크린 렌더링 최적화: GPU에서 통합 렌더링
                        .drawingGroup()
                        // Swift 6 Safe: rot, persp는 let. phase는 파라미터.
                        .scrollTransition { view, phase in
                            let angle: Double = phase.isIdentity ? 0
                                : (phase == .topLeading ? rot : -rot)
                            let scale: CGFloat = phase.isIdentity ? 1.0 : 0.75
                            let opacity: Double = phase.isIdentity ? 1.0 : 0.5

                            return view
                                .rotation3DEffect(
                                    .degrees(angle),
                                    axis: (x: 0, y: 1, z: 0),
                                    perspective: persp
                                )
                                .scaleEffect(scale)
                                .opacity(opacity)
                        }
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 60, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: Binding(get: { selectedIndex }, set: { if let v = $0 { selectedIndex = v } }))
        .onChange(of: selectedIndex) { _, _ in
            if hapticsEnabled {
                HapticsGenerator.triggerImpact(style: .light)
            }
        }
        .overlay(alignment: .bottom) {
            if items.count > 1 {
                CarouselIndicatorView(
                    style: indicatorStyle,
                    currentIndex: selectedIndex,
                    itemCount: items.count
                )
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct Album: Identifiable, Sendable {
    let id: Int
    let color: Color
    let name: String
}

#Preview("Cover Flow Carousel") {
    let albums: [Album] = [
        Album(id: 0, color: .orange, name: "Folklore"),
        Album(id: 1, color: .indigo, name: "Midnights"),
        Album(id: 2, color: .pink, name: "1989"),
        Album(id: 3, color: .teal, name: "Reputation"),
        Album(id: 4, color: .yellow, name: "Lover"),
    ]

    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.1).ignoresSafeArea()
        VStack {
            Spacer()
            CoverFlowCarousel(items: albums) { album in
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(album.color.gradient)
                        .shadow(color: album.color.opacity(0.6), radius: 20, y: 10)
                    Text(album.name)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                .frame(width: 200, height: 200)
            }
            Spacer()
        }
    }
}
#endif
