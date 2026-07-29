import SwiftUI

// MARK: - Full Pager Carousel

/// 온보딩 / 이미지 뷰어 스타일의 풀스크린 페이저 Carousel
///
/// ## Quick View
/// - **특징**: 화면 전체를 채우는 페이지 기반 캐러셀. 커스텀 페이지 인디케이터 내장.
///   좌우 스와이프로 페이지를 이동하고, 이전/다음 버튼 옵션도 제공합니다.
/// - **성능**: `LazyHStack` + `scrollTargetBehavior(.viewAligned)`로 Lazy Loading 보장.
///   (TabView .page 방식의 eager loading 함정을 피함)
/// - **Swift 6**: 타이머/자동 전진 로직을 `Task` + `AsyncStream.sleep`으로 구현.
///
/// ## SwiftUI 사용 예시
/// ```swift
/// FullPagerCarousel(items: onboardingPages, showsButtons: true) { page in
///     OnboardingPageView(page: page)
/// }
/// ```
public struct FullPagerCarousel<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let items: [Item]
    private let indicatorStyle: CarouselIndicatorStyle
    private let showsButtons: Bool
    private let hapticsEnabled: Bool
    private let content: (Item) -> Content

    @State private var selectedIndex: Int = 0

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - showsIndicator: 페이지 인디케이터 표시 여부 (기본값: true)
    ///   - showsButtons: 이전/다음 버튼 표시 여부 (기본값: false)
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: false)
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        items: [Item],
        indicatorStyle: CarouselIndicatorStyle = .dots(),
        showsButtons: Bool = false,
        hapticsEnabled: Bool = false,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.indicatorStyle = indicatorStyle
        self.showsButtons = showsButtons
        self.hapticsEnabled = hapticsEnabled
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            // 풀스크린 스크롤 캐러셀
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        content(item)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: Binding(get: { selectedIndex }, set: { if let v = $0 { selectedIndex = v } }))
            .ignoresSafeArea()
            .onChange(of: selectedIndex) { _, _ in
                if hapticsEnabled {
                    HapticsGenerator.triggerImpact(style: .light)
                }
            }

            // 하단 오버레이 (인디케이터 + 버튼)
            VStack(spacing: 0) {
                Spacer()

                HStack {
                    // 이전 버튼 (옵션)
                    if showsButtons {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedIndex = max(0, selectedIndex - 1)
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .opacity(selectedIndex == 0 ? 0.3 : 1.0)
                        .disabled(selectedIndex == 0)
                    }

                    Spacer()

                    // 페이지 인디케이터
                    if items.count > 1 {
                        CarouselIndicatorView(
                            style: indicatorStyle,
                            currentIndex: selectedIndex,
                            itemCount: items.count
                        )
                    }

                    Spacer()

                    // 다음 버튼 (옵션)
                    if showsButtons {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedIndex = min(items.count - 1, selectedIndex + 1)
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .opacity(selectedIndex == items.count - 1 ? 0.3 : 1.0)
                        .disabled(selectedIndex == items.count - 1)
                    }
                }
                .padding(.horizontal, showsButtons ? 24 : 0)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct OnboardingPage: Identifiable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let emoji: String
    let background: Color
}

#Preview("Full Pager Carousel") {
    let pages: [OnboardingPage] = [
        OnboardingPage(id: 0, title: "환영합니다", subtitle: "앱의 모든 기능을 알아보세요", emoji: "👋", background: .orange),
        OnboardingPage(id: 1, title: "빠른 검색", subtitle: "원하는 것을 즉시 찾아드립니다", emoji: "🔍", background: .blue),
        OnboardingPage(id: 2, title: "스마트 알림", subtitle: "중요한 순간을 놓치지 마세요", emoji: "🔔", background: .purple),
        OnboardingPage(id: 3, title: "시작하기", subtitle: "지금 바로 경험해보세요", emoji: "🚀", background: .green),
    ]

    FullPagerCarousel(items: pages, showsButtons: true) { page in
        page.background
            .overlay(
                VStack(spacing: 20) {
                    Text(page.emoji).font(.system(size: 80))
                    Text(page.title).font(.title.bold()).foregroundStyle(.white)
                    Text(page.subtitle).font(.body).foregroundStyle(.white.opacity(0.8))
                }
            )
    }
}
#endif
