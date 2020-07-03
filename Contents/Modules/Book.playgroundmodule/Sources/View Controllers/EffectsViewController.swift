// Created by Grant Emerson on 5/11/20.

import UIKit

public protocol EffectsVCDelegate: AnyObject {
    func effectsVC(_ effectsVC: EffectsViewController, didUpdateWithEffectValue effectValue: Sampler.AudioEffectValue)
}

public class EffectsViewController: UIViewController {
    
    public enum EffectParameter: Int {
        case reverb, delay, distortion, filterFrequency
        
        static let all: [EffectParameter] = [.reverb, .delay, .distortion, .filterFrequency]
        
        var name: String {
            switch self {
            case .reverb:
                return "Reverb"
            case .delay:
                return "Delay"
            case .distortion:
                return "Distortion"
            case .filterFrequency:
                return "Low Pass Filter"
            }
        }
    }
    
    // MARK: Properties
    
    public weak var delegate: EffectsVCDelegate?
    
    private lazy var knobViews: [KnobView] = {
        var knobViews = [KnobView]()
        
        for effectParameter in EffectParameter.all {
            let knobView = KnobView(id: effectParameter.rawValue, name: effectParameter.name)
            
            if effectParameter == .filterFrequency {
                knobView.value = 1
                knobView.valueFormatter = { value in
                    let hertz = (value * 5000)
                    return hertz.formattedAsHertz()
                }
            }
            
            knobView.addTarget(self, action: #selector(knobViewValueDidChange), for: .valueChanged)
            knobView.translatesAutoresizingMaskIntoConstraints = false
            knobViews.append(knobView)
        }
        
        return knobViews
    }()
    
    private lazy var knobGroupView: UIView = {
        let knobGroupView = UIView()
        knobGroupView.translatesAutoresizingMaskIntoConstraints = false
        return knobGroupView
    }()
    
    // MARK: View Controller Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    // MARK: Selector Methods
    
    @objc private func knobViewValueDidChange(_ sender: KnobView) {
        let value = sender.value
        let effectParameter = EffectParameter(rawValue: sender.id)!
        
        switch effectParameter {
        case .reverb:
            delegate?.effectsVC(self, didUpdateWithEffectValue: .reverb(wetDryMix: value * 100))
        case .delay:
            delegate?.effectsVC(self, didUpdateWithEffectValue: .delay(wetDryMix: value * 100))
        case .distortion:
            delegate?.effectsVC(self, didUpdateWithEffectValue: .distortion(wetDryMix: value * 100))
        case .filterFrequency:
            delegate?.effectsVC(self, didUpdateWithEffectValue: .lowPassFilter(frequency: value * 5000))
        }
    }
    
    // MARK: Private Methods
    
    private func setUpSubviews() {
        view.add(knobGroupView)
        knobViews.forEach(knobGroupView.addSubview)
        
        let highPriorityKnobGroupViewWidthConstraint = knobGroupView.widthAnchor.constraint(equalTo: view.widthAnchor)
        highPriorityKnobGroupViewWidthConstraint.priority = .defaultLow
        
        let highPriorityKnobGroupViewHeightConstraint = knobGroupView.heightAnchor.constraint(equalTo: view.heightAnchor)
        highPriorityKnobGroupViewHeightConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            knobGroupView.heightAnchor.constraint(equalTo: knobGroupView.widthAnchor),
            knobGroupView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            knobGroupView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor),
            highPriorityKnobGroupViewWidthConstraint,
            highPriorityKnobGroupViewHeightConstraint,
            knobGroupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            knobGroupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            knobViews[0].leadingAnchor.constraint(equalTo: knobGroupView.leadingAnchor),
            knobViews[0].trailingAnchor.constraint(equalTo: knobGroupView.centerXAnchor),
            knobViews[0].topAnchor.constraint(equalTo: knobGroupView.topAnchor),
            knobViews[0].bottomAnchor.constraint(equalTo: knobGroupView.centerYAnchor),
            
            knobViews[1].leadingAnchor.constraint(equalTo: knobGroupView.centerXAnchor),
            knobViews[1].trailingAnchor.constraint(equalTo: knobGroupView.trailingAnchor),
            knobViews[1].topAnchor.constraint(equalTo: knobGroupView.topAnchor),
            knobViews[1].bottomAnchor.constraint(equalTo: knobGroupView.centerYAnchor),
            
            knobViews[2].leadingAnchor.constraint(equalTo: knobGroupView.leadingAnchor),
            knobViews[2].trailingAnchor.constraint(equalTo: knobGroupView.centerXAnchor),
            knobViews[2].topAnchor.constraint(equalTo: knobGroupView.centerYAnchor),
            knobViews[2].bottomAnchor.constraint(equalTo: knobGroupView.bottomAnchor),
            
            knobViews[3].leadingAnchor.constraint(equalTo: knobGroupView.centerXAnchor),
            knobViews[3].trailingAnchor.constraint(equalTo: knobGroupView.trailingAnchor),
            knobViews[3].topAnchor.constraint(equalTo: knobGroupView.centerYAnchor),
            knobViews[3].bottomAnchor.constraint(equalTo: knobGroupView.bottomAnchor)
        ])
    }
    
    // MARK: Public Methods
    
    public func redrawViews() {
        knobViews.forEach { $0.setNeedsDisplay() }
    }
}
