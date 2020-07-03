// Created by Grant Emerson on 5/7/20.

import UIKit

public protocol SamplePadVCDelegate: AnyObject {
    func samplePadViewController(_ samplePadViewController: SamplePadViewController, didPress index: Int, with sampleType: SampleType)
    func samplePadViewController(_ samplePadViewController: SamplePadViewController, didRelease index: Int, with sampleType: SampleType)
    func samplePadViewController(_ samplePadViewController: SamplePadViewController, didSetBendAt index: Int, with sampleType: SampleType, to bend: Double)
}

public class SamplePadViewController: UIViewController {
    
    // MARK: Properties
    
    public var selectedFilm: Film = .gulliversTravels {
        didSet {
            samplePadGroupViews.forEach { $0.setFilm(selectedFilm) }
        }
    }
    
    public weak var delegate: SamplePadVCDelegate?
    
    private var tutorialView: TutorialView?
    
    private lazy var samplePadGroupViews: [SamplePadGroupView] = {
        var samplePadGroupViews = [SamplePadGroupView]()
        for sampleType in SampleType.all {
            let samplePadGroupView = SamplePadGroupView(sampleType: sampleType, selectionHandler: { [weak self] sampleType, index, isCurrentlyPressed in
                guard let self = self else { return }
                if isCurrentlyPressed {
                    self.pressedSamplePadAt(index, with: sampleType)
                } else {
                    self.releasedSamplePadAt(index, with: sampleType)
                }
            }, bendHandler: { [weak self] sampleType, index, bend in
                guard let self = self else { return }
                self.bentSamplePadAt(index, with: sampleType, to: bend)
            })
            samplePadGroupViews.append(samplePadGroupView)
        }
        return samplePadGroupViews
    }()
    
    // MARK: View Controller Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tutorialView != nil {
            updateTutorialViewPosition()
        }
    }
    
    // MARK: Private Methods
    
    private func setUpSubviews() {
        for samplePadGroupView in samplePadGroupViews {
            view.add(samplePadGroupView)
        }
        
        NSLayoutConstraint.activate([
            samplePadGroupViews[0].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            samplePadGroupViews[0].trailingAnchor.constraint(equalTo: view.centerXAnchor),
            samplePadGroupViews[0].topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            samplePadGroupViews[0].bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -2.5),
            
            samplePadGroupViews[1].leadingAnchor.constraint(equalTo: view.centerXAnchor),
            samplePadGroupViews[1].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            samplePadGroupViews[1].topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            samplePadGroupViews[1].bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -2.5),
            
            samplePadGroupViews[2].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            samplePadGroupViews[2].trailingAnchor.constraint(equalTo: view.centerXAnchor),
            samplePadGroupViews[2].topAnchor.constraint(equalTo: view.centerYAnchor, constant: 2.5),
            samplePadGroupViews[2].bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            
            samplePadGroupViews[3].leadingAnchor.constraint(equalTo: view.centerXAnchor),
            samplePadGroupViews[3].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            samplePadGroupViews[3].topAnchor.constraint(equalTo: view.centerYAnchor, constant: 2.5),
            samplePadGroupViews[3].bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
        ])
    }
    
    private func pressedSamplePadAt(_ index: Int, with sampleType: SampleType) {
        if let tutorialView = tutorialView {
            guard index == TutorialView.tutorialSampleIndex,
                sampleType == TutorialView.tutorialSampleType else { return }
            
            if tutorialView.selectedTutorialComponent == .touchSamplePad {
                tutorialView.advanceTutorialComponent()
            }
        }
        delegate?.samplePadViewController(self, didPress: index, with: sampleType)
    }
    
    private func releasedSamplePadAt(_ index: Int, with sampleType: SampleType) {
        if let tutorialView = tutorialView {
            guard index == TutorialView.tutorialSampleIndex,
                sampleType == TutorialView.tutorialSampleType else { return }
            
            if tutorialView.selectedTutorialComponent == .releaseSamplePad {
                tutorialView.advanceTutorialComponent()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tutorialView?.removeFromSuperview()
                    self.tutorialView = nil
                }
            }
        }
        delegate?.samplePadViewController(self, didRelease: index, with: sampleType)
    }
    
    private func bentSamplePadAt(_ index: Int, with sampleType: SampleType, to bendValue: Double) {
        if let tutorialView = tutorialView {
            guard index == TutorialView.tutorialSampleIndex,
                sampleType == TutorialView.tutorialSampleType else { return }
            
            if tutorialView.selectedTutorialComponent == .dragSamplePad && bendValue != 0 {
                tutorialView.advanceTutorialComponent()
            }
        }
        delegate?.samplePadViewController(self, didSetBendAt: index, with: sampleType, to: bendValue)
    }
    
    private func updateTutorialViewPosition() {
        guard let anchorView = samplePadGroupViews[TutorialView.tutorialSampleType.rawValue].getSamplePadView(at: TutorialView.tutorialSampleIndex) else {
            print("Couldn't find anchor view for tutorial view")
            return
        }
        
        let localAnchorPoint = CGPoint(x: anchorView.bounds.midX, y: anchorView.bounds.minY)
        let anchorPoint = anchorView.convert(localAnchorPoint, to: view)
        
        let width: CGFloat = 200
        let height: CGFloat = 150
        
        tutorialView?.frame = CGRect(x: anchorPoint.x - width / 2,
                                     y: anchorPoint.y - height,
                                     width: width,
                                     height: height)
    }
    
    // MARK: Public Methods
    
    public func startTutorial() {
        tutorialView = TutorialView()
        view.add(tutorialView!)
        updateTutorialViewPosition()
    }
}
