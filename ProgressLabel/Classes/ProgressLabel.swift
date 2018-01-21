import UIKit

/// Displays progress by filling stroked text.
@IBDesignable
open class ProgressLabel: UIView {
    
    /// Value between 0.0 and 1.0.
    @IBInspectable
    open var progress: CGFloat = 0.0 {
        didSet {
            progress = max(0, min(progress, 1))
            layoutLayers()
        }
    }
    
    /// Text to render.
    @IBInspectable
    open var text: String = "" {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    @IBInspectable
    open var textColor: UIColor = .black {
        didSet {
            strokedLayer.backgroundColor = textColor.cgColor
            filledLayer.backgroundColor = textColor.cgColor
        }
    }
    
    @IBInspectable
    open var fontName: String {
        get { return font.fontName }
        set { font = UIFont(name: newValue, size: fontSize) ?? font }
    }
    
    @IBInspectable
    open var fontSize: CGFloat {
        get { return font.pointSize }
        set { font = UIFont(name: fontName, size: newValue) ?? font }
    }
    
    @IBInspectable
    open var lineWidth: CGFloat = 1.0 {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open var font = UIFont.systemFont(ofSize: 14.0) {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open var textAlignment: NSTextAlignment = .center {
        didSet { setNeedsLayout() }
    }
    
    private lazy var strokedLayer: CALayer = makeSublayer()
    private lazy var filledLayer: CALayer = makeSublayer()
    
    override open var intrinsicContentSize: CGSize {
        let textSize = attributedString.size()
        return CGSize(width: ceil(textSize.width) + lineWidth, height: ceil(textSize.height) + lineWidth)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutLayers()
        updateTextMask()
    }
}

private extension ProgressLabel {
    var attributedString: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        return NSAttributedString(string: text, attributes: [.font: font, .paragraphStyle: style])
    }
    
    func makeSublayer() -> CALayer {
        let sublayer = CALayer()
        sublayer.anchorPoint = .zero
        sublayer.backgroundColor = textColor.cgColor
        layer.addSublayer(sublayer)
        return sublayer
    }
    
    func layoutLayers() {
        strokedLayer.frame = bounds
        filledLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
    
    func updateTextMask() {
        strokedLayer.mask = textMask(with: .stroke)
        filledLayer.mask = textMask(with: .fillStroke)
    }
    
    func textMask(with drawingMode: CGTextDrawingMode) -> CALayer {
        let maskLayer = CALayer()
        maskLayer.contentsGravity = kCAGravityResizeAspect
        maskLayer.frame = bounds
        maskLayer.contents = renderText(with: drawingMode)?.cgImage
        return maskLayer
    }
    
    func renderText(with drawingMode: CGTextDrawingMode) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setTextDrawingMode(drawingMode)
        context.setLineWidth(lineWidth)
        attributedString.draw(in: bounds)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension ProgressLabel {
    public func setProgressAnimated(_ progress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = filledLayer.bounds as NSValue
        animation.toValue = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height) as NSValue
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.progress = progress
        filledLayer.add(animation, forKey: nil)
    }
}
