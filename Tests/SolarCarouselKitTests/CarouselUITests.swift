import SwiftUI
import Testing
import ViewInspector
@testable import SolarCarouselKit

// MARK: - ViewInspector Conformances

extension CarouselPageIndicator: Inspectable {}
extension HeroBannerCarousel: Inspectable {}
extension InfiniteLoopCarousel: Inspectable {}

extension CarouselIndicatorView: Inspectable {}

// ViewInspector 0.9.x 에서는 swift-testing 지원이 제한적일 수 있으나, XCTest 대신 try 래퍼로 작동 가능.
@Suite("Carousel UI & Functional Tests")
@MainActor
struct CarouselUITests {

    // MARK: - Helper Models

    struct TestItem: Identifiable, Sendable {
        let id: Int
    }
    
    let items = (0..<5).map { TestItem(id: $0) }

    // MARK: - Page Indicator 테스트

    @Test("CarouselPageIndicator: Capsule 개수 및 상태 렌더링 검사")
    func pageIndicatorRendering() throws {
        let indicator = CarouselPageIndicator(currentIndex: 2, itemCount: 5)
        
        // 1. 전체 HStack 렌더링 확인
        let hStack = try indicator.inspect().hStack()
        #expect(hStack.count == 5, "아이템 수에 맞게 Capsule 5개가 렌더링되어야 함")
        
        // 2. 비활성 점 (인덱스 0)
        let shapes = try indicator.inspect().findAll(ViewType.Shape.self)
        let dot0 = shapes[0]
        let width0 = try dot0.fixedFrame().width
        #expect(width0 == 8, "비활성 점의 너비는 dotSize(8)여야 함")
        
        // 3. 활성 점 (인덱스 2)
        let dot2 = shapes[2]
        let width2 = try dot2.fixedFrame().width
        #expect(width2 == 24, "활성 점의 너비는 activeDotWidth(24)여야 함")
    }

    // MARK: - Carousel 렌더링 검사

    @Test("HeroBannerCarousel: 구조 및 ViewAligned 동작 검사")
    func heroBannerStructure() throws {
        let carousel = HeroBannerCarousel(items: items) { item in
            Text("Item \(item.id)")
        }
        
        // VStack을 찾아야 함
        let vStack = try carousel.inspect().vStack()
        
        // 1. 내부 ScrollView 존재 여부
        let scrollView = try vStack.scrollView(0)
        #expect(try scrollView.axes() == .horizontal)
        
        // ViewInspector가 scrollTargetBehavior를 직접 읽을 수 없지만, 
        // 렌더링이 문제 없이 이루어지는지 검증
        let hStack = try scrollView.lazyHStack()
        let forEach1 = try hStack.find(ViewType.ForEach.self)
        #expect(try forEach1.count == 5)
        
        // 2. 하단에 PageIndicator가 존재하는지
        _ = try vStack.view(CarouselIndicatorView.self, 1)
    }
    
    @Test("InfiniteLoopCarousel: 3배 복제(Virtual Tripling) 렌더링 검사")
    func infiniteLoopVirtualTripling() throws {
        let carousel = InfiniteLoopCarousel(items: items) { item in
            Text("Item \(item.id)")
        }
        
        let scrollView = try carousel.inspect().scrollView()
        let hStack = try scrollView.lazyHStack()
        
        // 아이템 5개가 3배 복제되었으므로 15개 렌더링 되어야 함
        let forEach2 = try hStack.find(ViewType.ForEach.self)
        let renderedCount = try forEach2.count
        #expect(renderedCount == 15, "가상 무한 루프를 위해 아이템 배열이 3배로 복제되어 렌더링되어야 함")
    }
}
