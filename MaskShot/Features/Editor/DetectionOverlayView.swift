import UIKit

final class DetectionOverlayView: UIView {
    var onToggleItem: ((SensitiveItem.ID) -> Void)?
    var onAddManualItem: ((CGRect) -> Void)?
    var onDeleteItem: ((SensitiveItem.ID) -> Void)?

    var isManualMode = false {
        didSet {
            draftRect = nil
            setNeedsDisplay()
        }
    }

    var items: [SensitiveItem] = [] {
        didSet { setNeedsDisplay() }
    }

    var imageRect: CGRect = .zero {
        didSet { setNeedsDisplay() }
    }

    private var dragStartPoint: CGPoint?
    private var draftRect: CGRect?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), imageRect != .zero else { return }

        for item in items {
            let displayRect = item.boundingBox.clampedToUnit().scaled(to: imageRect)
            let color = strokeColor(for: item)
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(item.isSelected ? 2.5 : 1.5)
            context.stroke(displayRect.insetBy(dx: 1, dy: 1))

            if item.isSelected {
                context.setFillColor(color.withAlphaComponent(item.riskLevel == .high ? 0.18 : 0.12).cgColor)
                context.fill(displayRect)
            }
        }

        if let draftRect {
            context.setStrokeColor(AppTheme.Color.primaryAccent.cgColor)
            context.setLineWidth(2)
            context.setLineDash(phase: 0, lengths: [7, 5])
            context.stroke(draftRect)
            context.setLineDash(phase: 0, lengths: [])
            context.setFillColor(AppTheme.Color.primaryAccent.withAlphaComponent(0.12).cgColor)
            context.fill(draftRect)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isManualMode,
              let point = touches.first?.location(in: self),
              imageRect.contains(point) else {
            super.touchesBegan(touches, with: event)
            return
        }

        dragStartPoint = point
        draftRect = CGRect(origin: point, size: .zero)
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isManualMode,
              let startPoint = dragStartPoint,
              let point = touches.first?.location(in: self) else {
            super.touchesMoved(touches, with: event)
            return
        }

        draftRect = rect(from: startPoint, to: clamped(point, to: imageRect))
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isManualMode {
            finishManualDrag()
            return
        }

        guard let point = touches.first?.location(in: self), imageRect.contains(point) else { return }
        let hitItem = items.reversed().first { item in
            item.boundingBox.clampedToUnit().scaled(to: imageRect).insetBy(dx: -10, dy: -10).contains(point)
        }
        guard let hitItem else { return }
        onToggleItem?(hitItem.id)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragStartPoint = nil
        draftRect = nil
        setNeedsDisplay()
    }
}

private extension DetectionOverlayView {
    func finishManualDrag() {
        defer {
            dragStartPoint = nil
            draftRect = nil
            setNeedsDisplay()
        }

        guard let draftRect,
              draftRect.width >= 12,
              draftRect.height >= 12 else {
            return
        }

        let boundedRect = draftRect.intersection(imageRect)
        guard boundedRect.width >= 12, boundedRect.height >= 12 else { return }

        let normalizedRect = CGRect(
            x: (boundedRect.minX - imageRect.minX) / imageRect.width,
            y: (boundedRect.minY - imageRect.minY) / imageRect.height,
            width: boundedRect.width / imageRect.width,
            height: boundedRect.height / imageRect.height
        ).clampedToUnit()

        onAddManualItem?(normalizedRect)
    }

    func rect(from startPoint: CGPoint, to endPoint: CGPoint) -> CGRect {
        CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        ).intersection(imageRect)
    }

    func clamped(_ point: CGPoint, to rect: CGRect) -> CGPoint {
        CGPoint(
            x: max(rect.minX, min(rect.maxX, point.x)),
            y: max(rect.minY, min(rect.maxY, point.y))
        )
    }

    @objc func onLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        let point = recognizer.location(in: self)
        guard imageRect.contains(point),
              let item = items.reversed().first(where: {
                  $0.type == .manual && $0.boundingBox.clampedToUnit().scaled(to: imageRect).insetBy(dx: -12, dy: -12).contains(point)
              }) else {
            return
        }
        onDeleteItem?(item.id)
    }

    func strokeColor(for item: SensitiveItem) -> UIColor {
        if !item.isSelected {
            return AppTheme.Color.secondaryText
        }

        switch item.riskLevel {
        case .high:
            return AppTheme.Color.danger
        case .medium:
            return AppTheme.Color.warning
        case .low:
            return AppTheme.Color.primaryAccent
        }
    }
}
