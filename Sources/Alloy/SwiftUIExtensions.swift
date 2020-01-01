import SwiftUI

public extension HorizontalAlignment {
    
    static func represented(by stringValue: String) -> Self? {
        switch stringValue {
        case "center":
            return .center
        case "leading":
            return .leading
        case "trailing":
            return .trailing
        default:
            return nil
        }
    }
    
}

public extension VerticalAlignment {
    
    static func represented(by stringValue: String) -> Self? {
        switch stringValue {
        case "center":
            return .center
        case "top":
            return .top
        case "bottom":
            return .bottom
        case "firstTextBaseline":
            return .firstTextBaseline
        case "lastTextBaseline":
            return .lastTextBaseline
        default:
            return nil
        }
    }
    
}
