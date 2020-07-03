// Created by Grant Emerson on 5/11/20.

import UIKit

public class KnobView: UIControl {
    
    // MARK: Properties
    
    public let id: Int
    public let name: String
    
    public var valueFormatter: ((Float) -> String)?
    
    public var value: Float = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var lastTouchPoint: CGPoint?
    
    // MARK: Init
    
    public init(id: Int = 0, name: String) {
        self.id = id
        self.name = name
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Draw View Contents
    
    public override func draw(_ rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        let minDimension = min(width, height)
                
        let inset: CGFloat = 5
        let indicatorRadius: CGFloat = 10
        let strokeWidth: CGFloat = 5
        let labelHeight: CGFloat = 20
        var labelOffset: CGFloat = 0
        
        if (minDimension - height - 2 * inset - 2 * labelHeight) < 0 {
            labelOffset = abs(minDimension - height - labelHeight - inset)
        }
        
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        
        let knobStartAngle: CGFloat = (3 * .pi) / 4
        let knobEndAngle: CGFloat = (9 * .pi) / 4
        
        let knobRadius = (minDimension - labelOffset) / 2 - inset - indicatorRadius
        let knobCenter = CGPoint(x: rect.midX, y: rect.midY + labelOffset / 2)
        
        let knobOutlinePath = UIBezierPath(arcCenter: knobCenter,
                                       radius: knobRadius,
                                       startAngle: knobStartAngle,
                                       endAngle: knobEndAngle,
                                       clockwise: true)
        UIColor.gray.setStroke()
        knobOutlinePath.lineWidth = strokeWidth
        knobOutlinePath.lineCapStyle = .round
        knobOutlinePath.stroke()
        
        let filledPathEndAngle = CGFloat(value) * (knobEndAngle - knobStartAngle) + knobStartAngle
        
        let filledKnobOutlinePath = UIBezierPath(arcCenter: knobCenter,
                                                 radius: knobRadius,
                                                 startAngle: knobStartAngle,
                                                 endAngle: filledPathEndAngle,
                                                 clockwise: true)
        UIColor.interactive.setStroke()
        filledKnobOutlinePath.lineWidth = strokeWidth
        filledKnobOutlinePath.lineCapStyle = .round
        filledKnobOutlinePath.stroke()
        
        let indicatorCenter = filledKnobOutlinePath.currentPoint
        let indicatorRect = CGRect(x: indicatorCenter.x - indicatorRadius,
                                   y: indicatorCenter.y - indicatorRadius,
                                   width: indicatorRadius * 2,
                                   height: indicatorRadius * 2)
        let indicatorPath = UIBezierPath(ovalIn: indicatorRect)
        UIColor.interactive.setFill()
        indicatorPath.fill()
        
        UIColor.darkGray.setStroke()
        indicatorPath.lineWidth = 2
        indicatorPath.stroke()
        
        let knobValueTextWidth: CGFloat = 50
        let knobValueTextHeight: CGFloat = 15
        let knobValueTextRect = CGRect(x: (width - knobValueTextWidth) / 2,
                                  y: knobOutlinePath.currentPoint.y - knobValueTextHeight / 2,
                                  width: knobValueTextWidth,
                                  height: knobValueTextHeight)
        
        let knobValueTextContent = valueFormatter?(value) ?? "\(Int((value * 100).rounded()))%"
        
        let knobValueTextStyle = NSMutableParagraphStyle()
        knobValueTextStyle.alignment = .center
        
        let knobValueTextFontAttributes = [
            .font: UIFont(name: "Futura", size: 13)!,
            .foregroundColor: UIColor.white,
            .paragraphStyle: knobValueTextStyle,
        ] as [NSAttributedString.Key: Any]
        
        let knobValueTextLetterHeight: CGFloat = knobValueTextContent.boundingRect(with: CGSize(width: knobValueTextWidth, height: knobValueTextHeight), options: .usesLineFragmentOrigin, attributes: knobValueTextFontAttributes, context: nil).height
        
        context.saveGState()
        
        context.clip(to: knobValueTextRect)
        
        let knobValueTextContentRect = CGRect(x: knobValueTextRect.minX,
                                         y: knobValueTextRect.minY + (knobValueTextRect.height - knobValueTextLetterHeight) / 2,
                                         width: knobValueTextWidth,
                                         height: knobValueTextHeight)
        knobValueTextContent.draw(in: knobValueTextContentRect, withAttributes: knobValueTextFontAttributes)
        
        context.restoreGState()
        
        let knobLabelTextWidth: CGFloat = width
        let knobLabelTextHeight: CGFloat = 20
        let knobLabelTextRect = CGRect(x: 0,
                                       y: knobCenter.y - knobRadius - indicatorRadius - labelHeight - inset,
                                       width: knobLabelTextWidth,
                                       height: knobLabelTextHeight)
        
        let knobLabelTextContent = "\(name)"
        
        let knobLabelTextStyle = NSMutableParagraphStyle()
        knobLabelTextStyle.alignment = .center
        
        let knobLabelTextFontAttributes = [
            .font: UIFont(name: "Futura", size: 15)!,
            .foregroundColor: UIColor.white,
            .paragraphStyle: knobLabelTextStyle,
        ] as [NSAttributedString.Key: Any]
        
        let knobLabelTextLetterHeight: CGFloat = knobLabelTextContent.boundingRect(with: CGSize(width: knobLabelTextWidth, height: knobLabelTextHeight), options: .usesLineFragmentOrigin, attributes: knobLabelTextFontAttributes, context: nil).height
        
        context.saveGState()
        
        context.clip(to: knobLabelTextRect)
        
        let knobLabelTextContentRect = CGRect(x: knobLabelTextRect.minX,
                                         y: knobLabelTextRect.minY + (knobLabelTextRect.height - knobLabelTextLetterHeight) / 2,
                                         width: knobLabelTextWidth,
                                         height: knobLabelTextHeight)
        knobLabelTextContent.draw(in: knobLabelTextContentRect, withAttributes: knobLabelTextFontAttributes)
        
        context.restoreGState()
    }
    
    // MARK: Touch Tracking
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        lastTouchPoint = touchPoint
        sendActions(for: .touchDown)
        return true
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        updateValueWith(touchPoint)
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else { return }
        let touchPoint = touch.location(in: self)
        updateValueWith(touchPoint)
        lastTouchPoint = nil
        super.endTracking(touch, with: event)
    }
    
    public override func cancelTracking(with event: UIEvent?) {
        lastTouchPoint = nil
        sendActions(for: .touchCancel)
    }
    
    // MARK: Private Methods
    
    private func updateValueWith(_ point: CGPoint) {
        guard lastTouchPoint != nil else { return }
        
        let distance = Float(point.y - lastTouchPoint!.y) * -1
        
        let updatedValue = (distance / Float(bounds.size.height)) + value
        value = max(0, min(1, updatedValue))
        sendActions(for: .valueChanged)
        
        lastTouchPoint = point
    }
}
