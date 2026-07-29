import UIKit

// MARK: - Solar Carousel View Controller

/// UIKit 앱에서 사용할 수 있는 Drop-in Carousel View Controller
///
/// ## Quick View
/// - **역할**: `UICollectionView` + `UICollectionViewCompositionalLayout`을 기반으로
///   `CarouselPreset`에 대응하는 UIKit Carousel을 제공합니다.
/// - **Swift 6 설계**: `Coordinator` 패턴 없이 `UICollectionViewDelegate`를 `@MainActor`
///   클래스인 `SolarCarouselViewController` 자체에서 구현. 데이터 레이스 없음.
/// - **사용처**: UIKit 기반 앱, 혹은 SwiftUI + UIViewControllerRepresentable 환경.
///
/// ## UIKit 사용 예시
/// ```swift
/// let carousel = SolarCarouselViewController(style: .heroBanner())
/// carousel.configure(
///     items: banners,
///     cellProvider: { cell, indexPath, banner in
///         cell.imageView.image = banner.image
///         cell.titleLabel.text = banner.title
///     }
/// )
/// carousel.onPageChange = { index in
///     print("Page changed to: \(index)")
/// }
/// addChild(carousel)
/// view.addSubview(carousel.view)
/// carousel.didMove(toParent: self)
/// ```
@MainActor
public final class SolarCarouselViewController: UIViewController {

    // MARK: - 공개 API

    /// 페이지가 변경될 때 호출되는 클로저 (인덱스 전달)
    public var onPageChange: ((Int) -> Void)?

    /// 특정 아이템(카드)이 탭(클릭)되었을 때 호출되는 클로저 (인덱스 전달)
    public var onItemTap: ((Int) -> Void)?

    /// 현재 표시 중인 페이지 인덱스
    public private(set) var currentIndex: Int = 0

    // MARK: - 내부 프로퍼티

    private let style: CarouselPreset
    private var hapticsEnabled: Bool
    private var itemCount: Int = 0

    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!

    // MARK: - 이니셜라이저

    /// - Parameters:
    ///   - style: 사용할 Carousel 스타일
    ///   - hapticsEnabled: 페이지 변경 시 햅틱 피드백 활성화 (기본값: 전역 설정)
    public init(
        style: CarouselPreset,
        hapticsEnabled: Bool? = nil
    ) {
        self.style = style
        self.hapticsEnabled = hapticsEnabled ?? CarouselKit.configuration.defaultHapticsEnabled
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) — Use init(style:) instead.")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPageControl()
    }

    // MARK: - 공개 설정 메서드

    /// 아이템 수와 셀 구성 클로저를 설정합니다.
    ///
    /// - Parameters:
    ///   - itemCount: 총 아이템 수
    ///   - showsPageControl: 페이지 컨트롤 표시 여부 (기본값: true)
    public func configure(itemCount: Int, showsPageControl: Bool = true) {
        self.itemCount = itemCount
        pageControl.numberOfPages = itemCount
        pageControl.isHidden = !showsPageControl || itemCount <= 1
        collectionView.reloadData()
    }

    // MARK: - CollectionView 설정

    private func setupCollectionView() {
        let layout = makeLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(CarouselKit.configuration.accentColor)
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        pageControl.isUserInteractionEnabled = false

        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }

    // MARK: - Compositional Layout 생성

    private func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] _, _ in
            guard let self else { return nil }
            return self.makeSection()
        }, configuration: config)
    }

    private func makeSection() -> NSCollectionLayoutSection {
        let peek = CarouselKit.configuration.defaultPeekAmount
        let spacing = CarouselKit.configuration.defaultSpacing

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupWidth: NSCollectionLayoutDimension
        switch style {
        case .fullPager:
            groupWidth = .fractionalWidth(1.0)
        case .coverFlow:
            groupWidth = .absolute(220)
        default:
            // peek 효과: 화면 너비에서 양쪽 peek 영역 제외
            groupWidth = .fractionalWidth(1.0)
        }

        let groupSize = NSCollectionLayoutSize(
            widthDimension: groupWidth,
            heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        let isFullPager: Bool
        if case .fullPager = style {
            isFullPager = true
        } else {
            isFullPager = false
        }

        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: isFullPager ? 0 : peek,
            bottom: 0,
            trailing: isFullPager ? 0 : peek
        )

        // Carousel 스냅 동작 설정
        switch style {
        case .fullPager:
            section.orthogonalScrollingBehavior = .paging
        default:
            section.orthogonalScrollingBehavior = .groupPagingCentered
        }

        // 페이지 변경 감지
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, scrollOffset, environment in
            MainActor.assumeIsolated {
                guard let self else { return }
                let pageWidth = environment.container.effectiveContentSize.width
                guard pageWidth > 0 else { return }
                let newIndex = Int((scrollOffset.x / pageWidth).rounded())
                if newIndex != self.currentIndex && newIndex >= 0 && newIndex < self.itemCount {
                    self.currentIndex = newIndex
                    self.pageControl.currentPage = newIndex
                    self.onPageChange?(newIndex)
                    if self.hapticsEnabled {
                        HapticsGenerator.triggerSelection()
                    }
                }
            }
        }

        return section
    }

    // MARK: - CollectionView 접근자

    /// 셀을 등록합니다.
    public func register<T: UICollectionViewCell>(_ cellType: T.Type, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellType, forCellWithReuseIdentifier: identifier)
    }

    /// DataSource를 설정합니다.
    public func setDataSource(_ dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = dataSource
    }
}

// MARK: - UICollectionViewDelegate

/// `@MainActor` 격리로 Swift 6 안전한 Delegate 구현
extension SolarCarouselViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if hapticsEnabled {
            HapticsGenerator.triggerImpact(style: .light)
        }
        
        let actualIndex = indexPath.item % itemCount // 무한 루프 등 확장 고려
        onItemTap?(actualIndex)
    }
}
