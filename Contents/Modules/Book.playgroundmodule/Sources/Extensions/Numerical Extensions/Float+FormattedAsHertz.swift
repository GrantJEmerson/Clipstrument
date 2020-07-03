// Created by Grant Emerson on 5/12/20.

import Foundation

public extension Float {
    func formattedAsHertz() -> String {
        if self < 1000 {
            return "\(Int(self.rounded())) Hz"
        } else {
            let kHz = self / 1000
            var formatString = "%.1f"
            if Int(kHz) == Int(kHz.rounded()) {
                formatString = "%.0f"
            }
            let formattedKHz = String(format: formatString, kHz)
            return "\(formattedKHz) kHz"
        }
    }
}
