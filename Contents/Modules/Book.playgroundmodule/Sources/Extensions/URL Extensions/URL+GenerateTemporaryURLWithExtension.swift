// Created by Grant Emerson on 5/8/20.

import Foundation

public extension URL {
    static func generateTemporaryURLWithExtension(_ pathExtension: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)
    }
}
