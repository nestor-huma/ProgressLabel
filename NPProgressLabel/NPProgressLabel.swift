//
//  NPProgressLabel.swift
//  NPProgressLabelExample
//
//  Created by Nestor Popko on 3/7/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

@IBDesignable
final public class NPProgressLabel: UIView {
    
    // MARK: public properties and methods
    @IBInspectable public var  text: String? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public var textAlignment: NSTextAlignment = .Center {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable public var textColor: UIColor = UIColor.blackColor() {
        didSet {
            strokedLayer.backgroundColor = textColor.CGColor
            filledLayer.backgroundColor = textColor.CGColor
        }
    }
    
    public var font = UIFont.systemFontOfSize(14.0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var fontName: String {
        get {
            return font.fontName
        }
        
        set {
            if let font = UIFont(name: newValue, size: fontSize) {
                self.font = font
            }
        }
    }
    
    @IBInspectable public var fontSize: CGFloat {
        get {
            return font.pointSize
        }
        
        set {
            if let font = UIFont(name: fontName, size: newValue) {
                self.font = font
            }
        }
    }
    
    @IBInspectable public var lineWidth: CGFloat = 1.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var progress: CGFloat = 0.0 {
        didSet {
            layoutLayers()
        }
    }
    
    public func setProgress(progress: CGFloat, animated: Bool = false) {
        if !animated {
            self.progress = progress
            return
        }
        
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = NSValue(CGRect: filledLayer.bounds)
        animation.toValue = NSValue(CGRect: CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height))
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.progress = progress
        filledLayer.addAnimation(animation, forKey: nil)
    }
    
    // MARK: private properties
    private let strokedLayer = CALayer()
    private let filledLayer = CALayer()
    private var textAttributes: [String: AnyObject] {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        return [NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
    }
    
    
    // MARK: initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        strokedLayer.anchorPoint = CGPointZero
        strokedLayer.backgroundColor = textColor.CGColor
        layer.addSublayer(strokedLayer)
        
        filledLayer.anchorPoint = CGPointZero
        filledLayer.backgroundColor = textColor.CGColor
        layer.addSublayer(filledLayer)
    }
    
    // MARK: layout
    override public func intrinsicContentSize() -> CGSize {
        if let text = text {
            let size = NSAttributedString(string: text, attributes: textAttributes).size()
            return CGSize(width: ceil(size.width) + lineWidth, height: ceil(size.height) + lineWidth)
        }
        return CGSizeZero
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutLayers()
        updateTextMask()
    }
    
    private func layoutLayers() {
        strokedLayer.frame = bounds
        filledLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
    
    // MARK: drawing
    private func updateTextMask() {
        let strokedMask = CALayer()
        strokedMask.contentsGravity = kCAGravityResizeAspect
        strokedMask.frame = bounds
        strokedMask.contents = renderTextWithDrawingMode(.Stroke)
        strokedLayer.mask = strokedMask
        
        let filledMask = CALayer()
        filledMask.contentsGravity = kCAGravityResizeAspect
        filledMask.frame = bounds
        filledMask.contents = renderTextWithDrawingMode(.FillStroke)
        filledLayer.mask = filledMask
    }
    
    private func renderTextWithDrawingMode(mode: CGTextDrawingMode) -> CGImage? {
        guard let text = text else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetTextDrawingMode(context, mode)
        CGContextSetLineWidth(context, lineWidth)
        
        text.drawInRect(bounds, withAttributes: textAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.CGImage
    }
}
