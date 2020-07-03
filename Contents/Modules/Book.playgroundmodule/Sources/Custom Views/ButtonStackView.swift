// Created by Grant Emerson on 5/10/20.

import UIKit

public class ButtonStackView: UIView {
    
    public enum Axis {
        case horizontal, vertical
    }
    
    // MARK: Properties
    
    public let axis: Axis
    public let buttonSize: CGSize
    public let buttons: [UIButton]
    
    private lazy var navigationButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = axis == .horizontal ? .horizontal : .vertical
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Init
    
    public init(_ buttons: [UIButton], buttonSize: CGSize, axis: Axis = .horizontal) {
        self.buttons = buttons
        self.buttonSize = buttonSize
        self.axis = axis
        super.init(frame: .zero)
        setUpView()
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Methods
    
    private func setUpView() {
        backgroundColor = .secondaryBackground
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 10
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpSubviews() {
        add(navigationButtonStackView)
        navigationButtonStackView.constrainToEdges()
        
        if axis == .horizontal {
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: ((buttonSize.width + 2) * CGFloat(buttons.count)) - 2),
                heightAnchor.constraint(equalToConstant: buttonSize.height)
            ])
        } else {
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: ((buttonSize.height + 2) * CGFloat(buttons.count)) - 2),
                widthAnchor.constraint(equalToConstant: buttonSize.width)
            ])
        }
    }

}
