import SwiftUI

/// 캐러셀 인디케이터 스타일을 정의하는 열거형
public enum CarouselIndicatorStyle: Sendable, Hashable, Equatable {
    /// 기본 알약 형태의 점 인디케이터
    case dots(activeColor: Color = .orange, inactiveColor: Color = .white.opacity(0.4))
    
    /// 텍스트 분수 형태 (예: 1 / 5)
    case fraction(font: Font = .subheadline, color: Color = .white)
    
    /// 선형 프로그레스 바
    case progressBar(activeColor: Color = .orange, inactiveColor: Color = .white.opacity(0.4), height: CGFloat = 4)
    
    /// 커스텀 뷰를 반환하는 클로저 (현재 인덱스, 전체 개수)
    case custom(@Sendable (Int, Int) -> AnyView)
    
    /// 인디케이터 숨김
    case none
    
    public static func == (lhs: CarouselIndicatorStyle, rhs: CarouselIndicatorStyle) -> Bool {
        switch (lhs, rhs) {
        case (.dots(let la, let li), .dots(let ra, let ri)):
            return la == ra && li == ri
        case (.fraction(let lf, let lc), .fraction(let rf, let rc)):
            return lf == rf && lc == rc
        case (.progressBar(let la, let li, let lh), .progressBar(let ra, let ri, let rh)):
            return la == ra && li == ri && lh == rh
        case (.custom, .custom):
            return true
        case (.none, .none):
            return true
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .dots(let active, let inactive):
            hasher.combine(0)
            hasher.combine(active)
            hasher.combine(inactive)
        case .fraction(let font, let color):
            hasher.combine(1)
            hasher.combine(font)
            hasher.combine(color)
        case .progressBar(let active, let inactive, let height):
            hasher.combine(2)
            hasher.combine(active)
            hasher.combine(inactive)
            hasher.combine(height)
        case .custom:
            hasher.combine(3)
        case .none:
            hasher.combine(4)
        }
    }
}

/// 선택된 `CarouselIndicatorStyle`에 따라 적절한 뷰를 렌더링하는 컨테이너 뷰
public struct CarouselIndicatorView: View {
    private let style: CarouselIndicatorStyle
    private let currentIndex: Int
    private let itemCount: Int
    
    public init(style: CarouselIndicatorStyle, currentIndex: Int, itemCount: Int) {
        self.style = style
        self.currentIndex = currentIndex
        self.itemCount = itemCount
    }
    
    public var body: some View {
        switch style {
        case .dots(let activeColor, let inactiveColor):
            CarouselPageIndicator(
                currentIndex: currentIndex,
                itemCount: itemCount,
                activeColor: activeColor,
                inactiveColor: inactiveColor
            )
        case .fraction(let font, let color):
            Text("\(currentIndex + 1) / \(itemCount)")
                .font(font)
                .foregroundColor(color)
                .monospacedDigit()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        case .progressBar(let activeColor, let inactiveColor, let height):
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(inactiveColor)
                        .frame(height: height)
                    
                    Capsule()
                        .fill(activeColor)
                        .frame(width: max(0, proxy.size.width * CGFloat(currentIndex + 1) / CGFloat(max(1, itemCount))), height: height)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentIndex)
                }
            }
            .frame(height: height)
            .padding(.horizontal, 20)
        case .custom(let viewBuilder):
            viewBuilder(currentIndex, itemCount)
        case .none:
            EmptyView()
        }
    }
}
