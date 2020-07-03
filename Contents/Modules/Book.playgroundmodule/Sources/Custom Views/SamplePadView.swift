// Created by Grant Emerson on 5/7/20.

import UIKit

public class SamplePadView: UIView {
    
    public typealias SelectionHandler = (_ index: Int, _ isCurrentlyPressed: Bool) -> ()
    public typealias BendHandler = (_ index: Int, _ bendPercent: Double) -> ()
    
    // MARK: Properties
    
    public let index: Int
    public var thumbnailImage: UIImage? = nil {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }
    
    private let selectionHandler: SelectionHandler
    private let bendHandler: BendHandler
    
    private let bendDistanceMinimum: CGFloat = 15
    
    private var touchStartingPoint: CGPoint?
    private var distancedDragged: CGFloat = 0
    private var isBendEnabled: Bool = false
    
    private lazy var upperBendIndicatorView: UIView = {
        let indicatorView = UIView()
        indicatorView.backgroundColor = .white
        indicatorView.alpha = 0
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    private lazy var lowerBendIndicatorView: UIView = {
        let indicatorView = UIView()
        indicatorView.backgroundColor = .white
        indicatorView.alpha = 0
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var selectedOverlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = .lightGray
        overlayView.alpha = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        return overlayView
    }()
    
    private lazy var selectionAnimator: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .linear) { [weak self] in
            self?.selectedOverlayView.alpha = 0.3
        }
        animator.pausesOnCompletion = true
        return animator
    }()
    
    // MARK: Init
    
    public init(index: Int, selectionHandler: @escaping SelectionHandler, bendHandler: @escaping BendHandler) {
        self.index = index
        self.selectionHandler = selectionHandler
        self.bendHandler = bendHandler
        super.init(frame: .zero)
        setUpView()
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview == nil else { return }
        stopAnimations()
    }
    
    // MARK: Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        
        touchStartingPoint = touch.location(in: self)
        distancedDragged = 0
        isBendEnabled = false
        select()
        setBendValueTo(0)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first,
            let touchStartingPoint = touchStartingPoint else { return }
        let updatedTouchLocation = touch.location(in: self)
        distancedDragged = updatedTouchLocation.y - touchStartingPoint.y
        
        if distancedDragged.magnitude > bendDistanceMinimum {
            isBendEnabled = true
        }
        
        if isBendEnabled {
            let bend = Double((updatedTouchLocation.y - bounds.midY) / (bounds.height / 2)) * -1
            setBendValueTo(bend)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        deselect()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        deselect()
    }
    
    // MARK: Private Methods
    
    private func setUpView() {
        backgroundColor = .interactive
        layer.cornerRadius = 5
        clipsToBounds = true
        isMultipleTouchEnabled = false
    }
    
    private func setUpSubviews() {
        add(upperBendIndicatorView, lowerBendIndicatorView, thumbnailImageView)
        thumbnailImageView.add(selectedOverlayView)
        
        thumbnailImageView.constrainToEdges(withInset: 3)
        selectedOverlayView.constrainToEdges()
        
        NSLayoutConstraint.activate([
            upperBendIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperBendIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            upperBendIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            upperBendIndicatorView.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            lowerBendIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerBendIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lowerBendIndicatorView.topAnchor.constraint(equalTo: centerYAnchor),
            lowerBendIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func stopAnimations() {
        selectionAnimator.fractionComplete = 1
        selectionAnimator.stopAnimation(true)
        selectionAnimator.finishAnimation(at: .current)
    }
    
    private func select() {
        selectionHandler(index, true)
        
        selectionAnimator.isReversed = false
        selectionAnimator.startAnimation()
    }
    
    private func deselect() {
        setBendValueTo(0)
        selectionHandler(index, false)
        
        selectionAnimator.isReversed = true
        selectionAnimator.startAnimation()
    }
    
    private func setBendValueTo(_ bend: Double) {
        bendHandler(index, bend)
        
        if bend >= 0 {
            upperBendIndicatorView.alpha = CGFloat(bend)
            lowerBendIndicatorView.alpha = 0
        } else {
            lowerBendIndicatorView.alpha = CGFloat(bend.magnitude)
            upperBendIndicatorView.alpha = 0
        }
    }
}
