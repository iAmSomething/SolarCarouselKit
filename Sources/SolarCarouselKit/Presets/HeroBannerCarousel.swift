import SwiftUI

// MARK: - Hero Banner Carousel

/// 앱스토어 / 쇼핑몰 스타일의 Hero Banner Carousel
///
/// ## Quick View
/// - **특징**: 양옆에 인접 카드가 살짝 보이는(peek) 효과로 스와이프를 자연스럽게 유도합니다.
///   `scrollTargetBehavior(.viewAligned)` 기반으로 카드가 중앙에 스냅됩니다.
/// - **성능**: `LazyHStack` 기반. 수백 개의 아이템도 메모리 효율적으로 처리.
/// - **Swift 6**: `@MainActor @Observable` ViewModel 패턴 채택. 데이터 레이스 없음.
///
/// ## SwiftUI 사용 예시
/// ```swift
/// HeroBannerCarousel(
///     items: banners,
///     peekAmount: 40,
///     spacing: 16,
///     hapticsEnabled: true
/// ) { banner in
///     AsyncImage(url: banner.imageURL) { img in
///         img.resizable().aspectRatio(contentMode: .fill)
///     } placeholder: { Color.gray }
///     .frame(height: 220)
///     .clipShape(RoundedRectangle(cornerRadius: 16))
/// }
/// ```
public struct HeroBannerCarousel<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let items: [Item]
    private let peekAmount: CGFloat
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let hapticsEnabled: Bool
    private let indicatorStyle: CarouselIndicatorStyle
    private let content: (Item) -> Content

    @State private var selectedIndex: Int = 0

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - peekAmount: 양옆에 보이는 인접 카드 크기 (기본값: 전역 설정)
    ///   - spacing: 카드 사이 간격 (기본값: 전역 설정)
    ///   - cornerRadius: 카드 모서리 반경 (기본값: 전역 설정)
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: 전역 설정)
    ///   - showsIndicator: 페이지 인디케이터 표시 여부 (기본값: true)
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        items: [Item],
        peekAmount: CGFloat? = nil,
        spacing: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        hapticsEnabled: Bool? = nil,
        indicatorStyle: CarouselIndicatorStyle = .dots(),
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.peekAmount = peekAmount ?? CarouselKit.configuration.defaultPeekAmount
        self.spacing = spacing ?? CarouselKit.configuration.defaultSpacing
        self.cornerRadius = cornerRadius ?? CarouselKit.configuration.defaultCornerRadius
        self.hapticsEnabled = hapticsEnabled ?? CarouselKit.configuration.defaultHapticsEnabled
        self.indicatorStyle = indicatorStyle
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 12) {
            // 캐러셀 스크롤 영역
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        content(item)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            // scrollTransition: phase 값만 사용 (Swift 6 Safe)
                            .scrollTransition { view, phase in
                                view
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.92)
                                    .opacity(phase.isIdentity ? 1.0 : 0.75)
                            }
                            .containerRelativeFrame(.horizontal) { total, _ in
                                total - (peekAmount * 2) - spacing
                            }
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, peekAmount, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: Binding(get: { selectedIndex }, set: { if let v = $0 { selectedIndex = v } }))
            .frame(maxWidth: .infinity)
            // 페이지 변경 감지 → 햅틱
            .onChange(of: selectedIndex) { _, _ in
                if hapticsEnabled {
                    HapticsGenerator.triggerSelection()
                }
            }

            // 페이지 인디케이터
            if items.count > 1 {
                CarouselIndicatorView(
                    style: indicatorStyle,
                    currentIndex: selectedIndex,
                    itemCount: items.count
                )
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct PreviewBanner: Identifiable, Sendable {
    let id: Int
    let color: Color
    let title: String
}

#Preview("Hero Banner Carousel") {
    let banners: [PreviewBanner] = [
        PreviewBanner(id: 0, color: .orange, title: "Today's Pick"),
        PreviewBanner(id: 1, color: .blue, title: "Editor's Choice"),
        PreviewBanner(id: 2, color: .purple, title: "Top Charts"),
        PreviewBanner(id: 3, color: .green, title: "New Arrivals"),
    ]

    ZStack {
        Color.black.ignoresSafeArea()
        HeroBannerCarousel(items: banners, hapticsEnabled: false) { banner in
            banner.color
                .overlay(
                    Text(banner.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                )
                .frame(height: 220)
        }
    }
}
#endif
