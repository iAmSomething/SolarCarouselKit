import Testing
@testable import SolarCarouselKit

// MARK: - 상태(CarouselState) 테스트

/// CarouselState의 순수 함수 로직을 UI 없이 검증합니다.
/// 상태 변이는 새로운 값을 반환하는 순수 함수이므로 직접 단위 테스트 가능합니다.
@Suite("CarouselState Tests")
struct StateTests {

    // MARK: - 초기화 검증

    @Test("기본 초기화 — 인덱스 0, 루프 없음")
    func defaultInit() {
        let state = CarouselState(itemCount: 5)
        #expect(state.currentIndex == 0)
        #expect(state.itemCount == 5)
        #expect(state.isLooping == false)
    }

    @Test("범위 초과 인덱스는 자동 보정되어야 함")
    func indexClampingOnInit() {
        let overState = CarouselState(currentIndex: 10, itemCount: 5)
        #expect(overState.currentIndex == 4, "10은 최대 4로 보정되어야 함")

        let negState = CarouselState(currentIndex: -3, itemCount: 5)
        #expect(negState.currentIndex == 0, "음수는 0으로 보정되어야 함")
    }

    // MARK: - 경계 상태 검증

    @Test("첫 번째 / 마지막 아이템 감지")
    func boundaryDetection() {
        let first = CarouselState(currentIndex: 0, itemCount: 5)
        #expect(first.isFirst == true)
        #expect(first.isLast == false)

        let last = CarouselState(currentIndex: 4, itemCount: 5)
        #expect(last.isFirst == false)
        #expect(last.isLast == true)

        let middle = CarouselState(currentIndex: 2, itemCount: 5)
        #expect(middle.isFirst == false)
        #expect(middle.isLast == false)
    }

    // MARK: - 다음/이전 인덱스 (루프 없음)

    @Test("루프 없음 — 첫 아이템의 previousIndex는 nil")
    func noPreviousAtStart() {
        let state = CarouselState(currentIndex: 0, itemCount: 5, isLooping: false)
        #expect(state.previousIndex == nil)
    }

    @Test("루프 없음 — 마지막 아이템의 nextIndex는 nil")
    func noNextAtEnd() {
        let state = CarouselState(currentIndex: 4, itemCount: 5, isLooping: false)
        #expect(state.nextIndex == nil)
    }

    @Test("루프 없음 — 중간 아이템의 인접 인덱스")
    func midItemNavigation() {
        let state = CarouselState(currentIndex: 2, itemCount: 5)
        #expect(state.previousIndex == 1)
        #expect(state.nextIndex == 3)
    }

    // MARK: - 다음/이전 인덱스 (루프 있음)

    @Test("루프 있음 — 마지막에서 next는 0")
    func loopingNextFromLast() {
        let state = CarouselState(currentIndex: 4, itemCount: 5, isLooping: true)
        #expect(state.nextIndex == 0, "루프 있음: 마지막 다음은 0")
    }

    @Test("루프 있음 — 처음에서 previous는 마지막")
    func loopingPreviousFromFirst() {
        let state = CarouselState(currentIndex: 0, itemCount: 5, isLooping: true)
        #expect(state.previousIndex == 4, "루프 있음: 처음 이전은 마지막")
    }

    // MARK: - 상태 변이 (순수 함수)

    @Test("advancing()이 새로운 상태를 반환해야 함")
    func advancingReturnsNewState() {
        let state = CarouselState(currentIndex: 2, itemCount: 5)
        let next = state.advancing()
        #expect(next.currentIndex == 3)
        #expect(state.currentIndex == 2, "원본 불변 확인") // 원본 불변
    }

    @Test("retreating()이 새로운 상태를 반환해야 함")
    func retreatingReturnsNewState() {
        let state = CarouselState(currentIndex: 3, itemCount: 5)
        let prev = state.retreating()
        #expect(prev.currentIndex == 2)
    }

    @Test("마지막에서 advancing()은 상태를 유지")
    func advancingAtEndNoChange() {
        let state = CarouselState(currentIndex: 4, itemCount: 5, isLooping: false)
        let same = state.advancing()
        #expect(same.currentIndex == 4)
    }

    @Test("movingTo(index:)로 특정 인덱스로 이동")
    func movingToIndex() {
        let state = CarouselState(currentIndex: 0, itemCount: 5)
        let jumped = state.movingTo(index: 3)
        #expect(jumped.currentIndex == 3)
    }

    @Test("범위 밖 인덱스로 movingTo는 상태를 유지")
    func movingToOutOfRange() {
        let state = CarouselState(currentIndex: 2, itemCount: 5)
        let same = state.movingTo(index: 10)
        #expect(same.currentIndex == 2, "범위 초과 시 현재 상태 유지")
    }

    // MARK: - 진행률 (Progress)

    @Test("진행률 계산")
    func progressCalculation() {
        let start = CarouselState(currentIndex: 0, itemCount: 5)
        #expect(start.progress == 0.0)

        let end = CarouselState(currentIndex: 4, itemCount: 5)
        #expect(end.progress == 1.0)

        let mid = CarouselState(currentIndex: 2, itemCount: 5)
        #expect(mid.progress == 0.5)
    }

    @Test("단일 아이템의 진행률은 0")
    func singleItemProgress() {
        let state = CarouselState(currentIndex: 0, itemCount: 1)
        #expect(state.progress == 0.0)
    }
}
