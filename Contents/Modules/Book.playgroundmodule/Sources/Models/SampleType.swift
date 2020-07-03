// Created by Grant Emerson on 5/8/20.

public enum SampleType: Int {
    case vocals
    case bass
    case chords
    case drums
    
    public static let all: [SampleType] = [.vocals, .bass, .chords, .drums]
    
    public var name: String {
        switch self {
        case .vocals:
            return "Vocals"
        case .bass:
            return "Bass"
        case .chords:
            return "Chords"
        case .drums:
            return "Drums"
        }
    }
}
