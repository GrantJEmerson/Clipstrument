// Created by Grant Emerson on 5/8/20.

public enum Film: Int {
    case gulliversTravels, doggoneTired, popeye
    
    public static let all = [gulliversTravels, doggoneTired, popeye]
    
    public var name: String {
        switch self {
        case .gulliversTravels:
            return "Gulliver's Travels"
        case .doggoneTired:
            return "Doggone Tired"
        case .popeye:
            return "Popeye"
        }
    }
    
    public var formattedName: String {
        name.replacingOccurrences(of: "'", with: "")
    }
}
