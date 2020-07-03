// Created by Grant Emerson on 5/7/20.

import UIKit

public extension UIView {
    func add(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
}


