public struct AlloyError: Error {
    
    public struct Reasons {
        
        public static let children = "Children"
        public static let exports = "Exports"
        public static let props = "Props"
        public static let source = "Source"
        
    }
    
    let message: String
    let reason: String
    
    public init(reason: String, message: String) {
        self.message = message
        self.reason = reason
    }
    
}

public extension AlloyError {
    
    static func children(_ message: String = "") -> Self {
        return AlloyError(reason: AlloyError.Reasons.children,
                          message: message)
    }
    
    static func exports(_ message: String = "") -> Self {
        return AlloyError(reason: AlloyError.Reasons.exports,
                          message: message)
    }
    
    static func props(_ message: String = "") -> Self {
        return AlloyError(reason: AlloyError.Reasons.props,
                          message: message)
    }
    
    static func source(_ message: String = "") -> Self {
        return AlloyError(reason:  AlloyError.Reasons.source,
                          message: message)
    }
    
}
