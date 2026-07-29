import UIKit
import SwiftUI

// MARK: - UIView + CarouselKit

/// UIView에 SolarCarouselKit 기반 Carousel을 직접 임베드하는 확장
///
/// ## Quick View
/// - **역할**: UIViewController를 거치지 않고 UIView에 직접 캐러셀을 추가합니다.
/// - **Swift 6**: `UIHostingController`를 통해 SwiftUI Preset을 UIKit에 삽입합니다.
///   `@MainActor` 격리로 UI 업데이트 안전.
/// - **내부 동작**: `UIHostingController`를 생성하여 UIView에 서브뷰로 추가합니다.
///
/// ## 사용 예시 (UIViewController 내부)
/// ```swift
/// // viewController 파라미터는 반드시 현재 UIViewController를 전달해야 합니다.
/// bannerView.embedCarouselKit(
///     style: .heroBanner(),
///     items: banners,
///     in: self
/// ) { banner in
///     BannerCell(banner: banner)
/// }
/// ```
public extension UIView {

    /// SwiftUI 기반 Carousel을 UIView에 임베드합니다.
    ///
    /// - Parameters:
    ///   - style: 사용할 Carousel 스타일
    ///   - items: 캐러셀에 표시할 아이템 배열
    ///   - viewController: 현재 UIViewController (HostingController의 부모)
    ///   - content: 각 아이템에 대한 SwiftUI 뷰 빌더
    @MainActor
    func embedCarouselKit<Item: Sendable & Identifiable, Content: View>(
        style: CarouselPreset,
        items: [Item],
        in viewController: UIViewController,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        let carouselView = SolarCarouselView(style: style, items: items, content: content)
        let hosting = UIHostingController(rootView: carouselView)

        viewController.addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        hosting.didMove(toParent: viewController)
    }
}
