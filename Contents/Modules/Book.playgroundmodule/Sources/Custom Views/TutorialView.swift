// Created by Grant Emerson on 5/14/20.

import UIKit

public class TutorialView: UIView {
    
    public enum TutorialComponent: Int {
        case touchSamplePad, dragSamplePad, releaseSamplePad, complete, animating
                
        var instruction: String? {
            switch self {
            case .touchSamplePad:
                return "Tap and Hold to Loop Me!"
            case .dragSamplePad:
                return "Awesome! Now Slide Up or Down to Bend My Pitch."
            case .releaseSamplePad:
                return "You’re a Pro! Release Your Finger to Stop the Loop."
            case .complete:
                return nil
            case .animating:
                return nil
            }
        }
    }
    
    // MARK: Properties
    
    public static let tutorialSampleType = SampleType.chords
    public static let tutorialSampleIndex = 1
    
    public private(set) var selectedTutorialComponent: TutorialComponent = .touchSamplePad
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Futura", size: 18)
        label.text = selectedTutorialComponent.instruction
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Init
    
    public init() {
        super.init(frame: .zero)
        setUpView()
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Draw
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        
        let arrowWidth: CGFloat = 10
        let arrowHeight: CGFloat = 10
        let width = rect.width
        let height = rect.height
        let backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        
        let contentRect = CGRect(x: 0, y: 0, width: width, height: height - arrowHeight)
        let contentRectPath = UIBezierPath(roundedRect: contentRect, cornerRadius: 20)
        backgroundColor.setFill()
        contentRectPath.fill()
        
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: (width - arrowWidth) / 2, y: height - arrowHeight))
        arrowPath.addLine(to: CGPoint(x: width / 2, y: height))
        arrowPath.addLine(to: CGPoint(x: (width + arrowWidth) / 2, y: height - arrowHeight))
        arrowPath.close()
        arrowPath.fill()
    }
    
    // MARK: Private Methods
    
    private func setUpView() {
        backgroundColor = .clear
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    private func setUpSubviews() {
        add(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            instructionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            instructionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
        
    }
    
    // MARK: Public Methods
    
    public func advanceTutorialComponent() {
        let newRawValue = selectedTutorialComponent.rawValue + 1
        guard let newTutorialComponent = TutorialComponent(rawValue: newRawValue) else { return }
        
        selectedTutorialComponent = .animating
        

        if newTutorialComponent == .complete {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                self.alpha = 0
            })
        }
        
        UIView.transition(with: instructionLabel, duration: 0.5, options: [.allowUserInteraction, .transitionCrossDissolve], animations: {
            self.instructionLabel.text = newTutorialComponent.instruction
        }) { _ in
            self.selectedTutorialComponent = newTutorialComponent
        }
    }
}
