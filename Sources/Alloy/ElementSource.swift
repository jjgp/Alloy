import SwiftUI

public protocol ElementSource: ElementConvertible {
    
    associatedtype Body: View
    
    var type: String { get }
    
    func body(props: Props) throws -> Self.Body
    
}

public protocol ElementConvertible {
    
    var type: String { get }
    
    func toElement(passing props: Props) -> Element
    
}

public extension ElementSource {
    
    func toElement(passing props: Props) -> Element {
        return .init(source: self, props: props)
    }
    
}

public struct ElementSourceError: Error {
    
    public struct Reasons {
        
        public static var children: String {
            "Children"
        }
        public static var props: String {
            "Props"
        }
        
    }
    
    let message: String
    let reason: String
    
    public init(reason: String, message: String) {
        self.message = message
        self.reason = reason
    }
    
    // TODO: conform to string convertibles here
    
}

public extension ElementSourceError {
    
    static func childrenError(_ message: String = "") -> Error {
        return ElementSourceError(reason: Reasons.children,
                                  message: message)
    }
    
    static func propsError(_ message: String = "") -> Error {
        return ElementSourceError(reason: Reasons.props,
                                  message: message)
    }
    
}

public struct FunctionSource: ElementSource {
    
    public let type = "Function"
    
    public func body(props: Props) throws -> some View {
        guard let exports: Element.Exports = props.dynamicallyCall(withArguments: []).toTypedObject() else {
            // TODO: need specific fn error for this!
            throw ElementSourceError.propsError()
        }
        return exports.element
    }
    
}

public struct ButtonSource: ElementSource {
    
    public let type = "Button"
    
    public func body(props: Props) throws -> some View {
        return Button(action: {
            props.action()
        }) {
            // TODO: perhaps use `label` prop?
            Text("Hello, world")
        }
    }
    
}

public struct HStackSource: ElementSource {
    
    public let type = "HStack"
    
    public func body(props: Props) throws -> some View {
        guard let children = props.children.toChildren() else {
            throw ElementSourceError.childrenError()
        }
        
        let alignment = props.alignment.toString()
            .flatMap { VerticalAlignment.represented(by: $0) }
            ?? .center
        let spacing = CGFloat(truncating: props.spacing.toNumber() ?? 0)
        
        return HStack(alignment: alignment, spacing: spacing) {
            children
        }
    }
    
}

public struct TextSource: ElementSource {
    
    public let type = "Text"
    
    public func body(props: Props) throws -> some View {
        let verbatim = props.verbatim.toString() ?? ""
        return Text(verbatim: verbatim)
    }
    
}

public struct VStackSource: ElementSource {
    
    public let type = "VStack"
    
    public func body(props: Props) throws -> some View {
        guard let children = props.children.toChildren() else {
            throw ElementSourceError.childrenError()
        }
        
        let alignment = props.alignment.toString()
            .flatMap { HorizontalAlignment.represented(by: $0) }
            ?? .center
        let spacing = CGFloat(truncating: props.spacing.toNumber() ?? 0)
        
        return VStack(alignment: alignment, spacing: spacing) {
            children
        }
    }
    
}
