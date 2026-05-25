import SnapKit
import UIKit

protocol RedactionImageViewDelegate: AnyObject {
    func redactionImageView(_ view: RedactionImageView, didUpdate geometry: ImageDisplayGeometry)
}

final class RedactionImageView: UIView {
    weak var delegate: RedactionImageViewDelegate?

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private(set) var geometry = ImageDisplayGeometry.aspectFit(imageSize: .zero, in: .zero)

    var image: UIImage? {
        didSet {
            imageView.image = image
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateImageFrame()
    }
}

extension RedactionImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

private extension RedactionImageView {
    func setupView() {
        backgroundColor = AppTheme.Color.elevatedSurface
        layer.cornerRadius = AppTheme.Radius.large
        layer.borderColor = AppTheme.Color.border.cgColor
        layer.borderWidth = 1
        clipsToBounds = true

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bouncesZoom = true

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        addSubview(scrollView)
        scrollView.addSubview(imageView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateImageFrame() {
        scrollView.frame = bounds
        guard let image else {
            geometry = ImageDisplayGeometry.aspectFit(imageSize: .zero, in: bounds.size)
            imageView.frame = bounds
            delegate?.redactionImageView(self, didUpdate: geometry)
            return
        }

        let nextGeometry = ImageDisplayGeometry.aspectFit(imageSize: image.size, in: bounds.size)
        geometry = nextGeometry
        scrollView.zoomScale = 1
        scrollView.contentSize = bounds.size
        imageView.frame = nextGeometry.displayedImageRect
        delegate?.redactionImageView(self, didUpdate: nextGeometry)
    }
}
