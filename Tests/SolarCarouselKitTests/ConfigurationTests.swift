import Testing
@testable import SolarCarouselKit

// MARK: - 설정 테스트

@Suite("CarouselConfiguration Tests")
struct ConfigurationTests {

    // MARK: - 기본값 검증

    @Test("기본 설정값이 올바르게 초기화되어야 함")
    func defaultConfigurationValues() {
        let config = CarouselConfiguration.default
        #expect(config.defaultAutoScrollInterval == nil)
        #expect(config.defaultAutoScrollLoops == true)
        #expect(config.defaultSpacing == 12)
        #expect(config.defaultPeekAmount == 32)
        #expect(config.defaultCornerRadius == 16)
        #expect(config.defaultHapticsEnabled == false)
    }

    // MARK: - 커스텀 설정 검증

    @Test("커스텀 설정으로 초기화 가능해야 함")
    func customConfigurationInit() {
        let config = CarouselConfiguration(
            defaultAutoScrollInterval: 5.0,
            defaultSpacing: 20,
            defaultHapticsEnabled: true
        )
        #expect(config.defaultAutoScrollInterval == 5.0)
        #expect(config.defaultSpacing == 20)
        #expect(config.defaultHapticsEnabled == true)
    }

    // MARK: - Sendable / Equatable 검증

    @Test("CarouselConfiguration은 Equatable을 준수해야 함")
    func configurationEquality() {
        let config1 = CarouselConfiguration.default
        let config2 = CarouselConfiguration.default
        #expect(config1 == config2)
    }

    @Test("서로 다른 설정은 같지 않아야 함")
    func configurationInequality() {
        let config1 = CarouselConfiguration(defaultSpacing: 12)
        let config2 = CarouselConfiguration(defaultSpacing: 20)
        #expect(config1 != config2)
    }
}
