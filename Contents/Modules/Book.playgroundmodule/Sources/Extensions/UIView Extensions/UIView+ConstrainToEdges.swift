// Created by Grant Emerson on 5/7/20.

import UIKit

public extension UIView {
    func constrainToEdges(withInset inset: CGFloat = 0) {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -inset),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -inset)
        ])
    }
}
