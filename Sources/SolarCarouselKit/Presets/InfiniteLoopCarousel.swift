import SwiftUI

// MARK: - Infinite Loop Carousel

/// 자동 무한 루프 롤링 배너 Carousel
///
/// ## Quick View
/// - **특징**: 마지막 아이템 이후 자동으로 첫 아이템으로 돌아가는 무한 루프 캐러셀.
///   뷰가 나타날 때 자동 시작, 사라질 때 자동 정지합니다.
/// - **구현 방식**: 실제 아이템 배열을 3배로 복제(가상 무한 루프)하여 자연스러운 순환 구현.
///   실제 무한 스크롤처럼 보이되 성능 문제가 없습니다.
/// - **Swift 6**: 자동 스크롤 타이머를 `Task { try? await Task.sleep }` 패턴으로 구현.
///   `@Sendable` 클로저 문제 없음. 뷰 소멸 시 Task 자동 취소.
///
/// ## SwiftUI 사용 예시
/// ```swift
/// InfiniteLoopCarousel(items: headlines, interval: 3.0) { headline in
///     HeadlineCard(headline: headline)
///         .frame(height: 120)
/// }
/// ```
public struct InfiniteLoopCarousel<Item: Sendable & Identifiable, Content: View>: View {

    // MARK: - 파라미터

    private let items: [Item]
    private let interval: TimeInterval
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let hapticsEnabled: Bool
    private let indicatorStyle: CarouselIndicatorStyle
    private let content: (Item) -> Content

    // 실제 아이템 수
    private var itemCount: Int { items.count }

    // 3배 복제된 가상 배열 (무한 루프용 인덱스)
    // 중간 블록(itemCount ~ 2*itemCount-1)을 초기 위치로 사용
    private var virtualItems: [(offset: Int, item: Item)] {
        let repeated = items + items + items
        return repeated.enumerated().map { ($0, $1) }
    }

    // MARK: - 내부 상태
    @State private var internalIndex: Int?
    @State private var isUserInteracting: Bool = false
    @State private var autoScrollTask: Task<Void, Never>?

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - items: 캐러셀에 표시할 아이템 배열 (최소 2개 이상)
    ///   - interval: 자동 전환 간격 (초, 기본값: 3.0)
    ///   - spacing: 카드 사이 간격 (기본값: 전역 설정)
    ///   - cornerRadius: 카드 모서리 반경 (기본값: 전역 설정)
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: false)
    ///   - content: 각 아이템에 대한 뷰 빌더
    public init(
        items: [Item],
        interval: TimeInterval = 3.0,
        spacing: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        hapticsEnabled: Bool = false,
        indicatorStyle: CarouselIndicatorStyle = .none,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.interval = max(0.5, interval)
        self.spacing = spacing ?? CarouselKit.configuration.defaultSpacing
        self.cornerRadius = cornerRadius ?? CarouselKit.configuration.defaultCornerRadius
        self.hapticsEnabled = hapticsEnabled
        self.indicatorStyle = indicatorStyle
        self.content = content
        // 중간 블록에서 시작 (가상 무한)
        _internalIndex = State(initialValue: items.count)
    }

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(virtualItems, id: \.offset) { offset, item in
                    content(item)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .scrollTransition { view, phase in
                            view
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.94)
                                .opacity(phase.isIdentity ? 1.0 : 0.7)
                        }
                        .containerRelativeFrame(.horizontal) { total, _ in
                            total - 80
                        }
                        .id(offset)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 40, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $internalIndex)
        .trackScrollPhase(isInteracting: $isUserInteracting)
        // 자동 스크롤 시작
        .onAppear {
            startAutoScroll()
        }
        // 뷰 소멸 시 Task 취소 (Swift 6 Safe: Task는 자동으로 cancel됨)
        .onDisappear {
            autoScrollTask?.cancel()
            autoScrollTask = nil
        }
        .onChange(of: internalIndex) { _, newIndex in
            if hapticsEnabled {
                HapticsGenerator.triggerSelection()
            }
            // 경계 도달 시 반대 끝으로 순간이동 (가상 무한 루프)
            if let newIndex {
                handleBoundaryWrap(newIndex: newIndex)
            }
        }
        
        // 인디케이터 오버레이
        .overlay(alignment: .bottom) {
            if items.count > 1 {
                CarouselIndicatorView(
                    style: indicatorStyle,
                    currentIndex: (internalIndex ?? items.count) % items.count,
                    itemCount: items.count
                )
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - 자동 스크롤

    private func startAutoScroll() {
        guard itemCount > 1 else { return }
        autoScrollTask?.cancel()

        // Swift 6 Safe: Task { @MainActor in ... } 패턴
        // self 전체 캡처가 아닌 Task 내부에서 직접 상태 변경
        autoScrollTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled, !isUserInteracting else { continue }
                withAnimation(.easeInOut(duration: 0.5)) {
                    internalIndex = (internalIndex ?? 0) + 1
                }
            }
        }
    }

    // MARK: - 경계 처리 (순간이동)

    @MainActor
    private func handleBoundaryWrap(newIndex: Int) {
        // 첫 번째 블록 끝에 도달 → 중간 블록으로 이동
        if newIndex < itemCount {
            DispatchQueue.main.async {
                internalIndex = newIndex + itemCount
            }
        }
        // 세 번째 블록 시작에 도달 → 두 번째 블록으로 이동
        else if newIndex >= itemCount * 2 {
            DispatchQueue.main.async {
                internalIndex = newIndex - itemCount
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct NewsHeadline: Identifiable, Sendable {
    let id: Int
    let color: Color
    let category: String
    let headline: String
}

#Preview("Infinite Loop Carousel") {
    let headlines: [NewsHeadline] = [
        NewsHeadline(id: 0, color: .red, category: "속보", headline: "새로운 Swift 6 릴리즈 발표"),
        NewsHeadline(id: 1, color: .blue, category: "기술", headline: "SwiftUI의 새로운 Animation API"),
        NewsHeadline(id: 2, color: .green, category: "오픈소스", headline: "SolarKits v1.0 출시 임박"),
        NewsHeadline(id: 3, color: .purple, category: "WWDC", headline: "Apple Intelligence 국내 지원 확대"),
    ]

    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.1).ignoresSafeArea()
        InfiniteLoopCarousel(items: headlines, interval: 2.5) { headline in
            HStack(spacing: 16) {
                Text(headline.category)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(headline.color, in: Capsule())

                Text(headline.headline)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 0)
    }
}
#endif

// MARK: - iOS 버전에 따른 Scroll Phase 호환성 헬퍼

private extension View {
    @ViewBuilder
    func trackScrollPhase(isInteracting: Binding<Bool>) -> some View {
        if #available(iOS 18.0, *) {
            self.onScrollPhaseChange { oldPhase, newPhase in
                isInteracting.wrappedValue = (newPhase == .interacting || newPhase == .decelerating)
            }
        } else {
            // iOS 17에서는 멈추지 않음
            self
        }
    }
}
