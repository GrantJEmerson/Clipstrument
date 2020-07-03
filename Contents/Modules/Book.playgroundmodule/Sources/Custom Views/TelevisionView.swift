// Created by Grant Emerson on 5/10/20.

import UIKit

public class TelevisionView: UIView {
    public override func draw(_ rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
                
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        
        let tvRect = CGRect(x: 0, y: 0, width: width, height: height)
        let tvBodyPath = UIBezierPath(roundedRect: tvRect, cornerRadius: 20)
        UIColor.darkGray.setFill()
        tvBodyPath.fill()
        
        let screenRect = CGRect(x: 20, y: 20, width: width - 40, height: height - 60)
        let screenPath = UIBezierPath(roundedRect: screenRect, cornerRadius: 10)
        UIColor.primaryBackground.setFill()
        screenPath.fill()

        let vhsWidth: CGFloat = 100
        let vhsHeight: CGFloat = 20
        let vhsRect = CGRect(x: (width - vhsWidth) / 2, y: height - 10 - vhsHeight, width: vhsWidth, height: vhsHeight)
        let vhsSlotPath = UIBezierPath(roundedRect: vhsRect, cornerRadius: 5)
        UIColor.primaryBackground.setFill()
        vhsSlotPath.fill()
        
        UIColor.gray.setStroke()
        vhsSlotPath.lineWidth = 2
        vhsSlotPath.stroke()

        
        let vhsTextWidth: CGFloat = 40
        let vhsTextHeight: CGFloat = 20
        let vhsTextRect = CGRect(x: (width - vhsTextWidth) / 2, y: height - 10 - vhsTextHeight, width: vhsTextWidth, height: vhsTextHeight)
        
        let vhsTextContent = "VHS"
        
        let vhsTextStyle = NSMutableParagraphStyle()
        vhsTextStyle.alignment = .center
        
        let vhsTextFontAttributes = [
            .font: UIFont(name: "Menlo-Italic", size: 15)!,
            .foregroundColor: UIColor.white,
            .paragraphStyle: vhsTextStyle,
        ] as [NSAttributedString.Key: Any]

        let vhsLetterHeight: CGFloat = vhsTextContent.boundingRect(with: CGSize(width: vhsTextWidth, height: vhsTextHeight), options: .usesLineFragmentOrigin, attributes: vhsTextFontAttributes, context: nil).height
        
        context.saveGState()
        
        context.clip(to: vhsTextRect)
        
        let vhsTextContentRect = CGRect(x: vhsTextRect.minX, y: vhsTextRect.minY + (vhsTextRect.height - vhsLetterHeight) / 2, width: vhsTextWidth, height: vhsTextHeight)
        vhsTextContent.draw(in: vhsTextContentRect, withAttributes: vhsTextFontAttributes)
        
        context.restoreGState()
        
        let knobDiameter: CGFloat = 20
        let indicatorHeight: CGFloat = 10
        let indicatorWidth: CGFloat = 2
        let spacer: CGFloat = 10
        
        let leftKnobRect = CGRect(x: vhsRect.minX - spacer - knobDiameter, y: vhsRect.minY, width: knobDiameter, height: knobDiameter)
        let leftKnobPath = UIBezierPath(ovalIn: leftKnobRect)
        UIColor.darkGray.setFill()
        leftKnobPath.fill()
        
        UIColor.gray.setStroke()
        leftKnobPath.lineWidth = 2
        leftKnobPath.stroke()

        let leftKnobIndicatorRect = CGRect(x: leftKnobRect.minX, y: leftKnobRect.midY - indicatorWidth / 2, width: indicatorHeight, height: indicatorWidth)
        let leftKnobIndicatorPath = UIBezierPath(roundedRect: leftKnobIndicatorRect, cornerRadius: 1)
        UIColor.gray.setFill()
        leftKnobIndicatorPath.fill()
        
        let rightKnobRect = CGRect(x: vhsRect.maxX + spacer, y: vhsRect.minY, width: knobDiameter, height: knobDiameter)
        let rightKnobPath = UIBezierPath(ovalIn: rightKnobRect)
        UIColor.darkGray.setFill()
        rightKnobPath.fill()
        
        UIColor.gray.setStroke()
        rightKnobPath.lineWidth = 2
        rightKnobPath.stroke()

        let rightKnobIndicatorRect = CGRect(x: rightKnobRect.minX, y: rightKnobRect.midY - indicatorWidth / 2, width: indicatorHeight, height: indicatorWidth)
        let rightKnobIndicatorPath = UIBezierPath(roundedRect: rightKnobIndicatorRect, cornerRadius: 1)
        UIColor.gray.setFill()
        rightKnobIndicatorPath.fill()

        context.restoreGState()
    }
}
