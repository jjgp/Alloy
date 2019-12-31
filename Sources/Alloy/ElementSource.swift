import SwiftUI

public protocol ElementSource: AnyElementSourceConvertible {
    
    associatedtype Body: View
    
    var type: String { get }
    
    func body(props: Props?) -> Self.Body
    
}

public struct AnyElementSource {
    
    let bodyErased: (Props?) -> AnyView
    func body(props: Props?) -> AnyView {
        bodyErased(props)
    }
    let type: String
    
    init<E: ElementSource>(_ source: E) {
        bodyErased = {
            AnyView(source.body(props: $0))
        }
        self.type = source.type
    }
    
}

public protocol AnyElementSourceConvertible {
    
    var asAnyElementSource: AnyElementSource { get }
    
}

public extension ElementSource {
    
    var asAnyElementSource: AnyElementSource {
        .init(self)
    }
    
}

public struct VStackSource: ElementSource {
    
    public let type = "VStack"
    
    public func body(props: Props?) -> some View {
        let alignment: HorizontalAlignment
        switch props?.alignment?.stringValue {
        case "leading":
            alignment = .leading
        case "trailing":
            alignment = .trailing
        default:
            alignment = .center
        }
        let spacing = CGFloat(truncating: props?.spacing?.numberValue ?? 0)
        
        return VStack(alignment: alignment, spacing: spacing) {
            props?.children?.childrenValue ?? .emptyChildren
        }
    }
    
}

public struct HStackSource: ElementSource {
    
    public let type = "HStack"
    
    public func body(props: Props?) -> some View {
        let alignment: VerticalAlignment
        switch props?.alignment?.stringValue {
        case "top":
            alignment = .top
        case "bottom":
            alignment = .bottom
        case "firstTextBaseline":
            alignment = .firstTextBaseline
        case "lastTextBaseline":
            alignment = .lastTextBaseline
        default:
            alignment = .center
        }
        let spacing = CGFloat(truncating: props?.spacing?.numberValue ?? 0)
        
        return HStack(alignment: alignment, spacing: spacing) {
            props?.children?.childrenValue ?? .emptyChildren
        }
    }
    
}

public struct TextSource: ElementSource {
    
    public let type = "Text"
    
    public func body(props: Props?) -> some View {
        let verbatim: String = props?.verbatim?.stringValue ?? ""
        return Text(verbatim: verbatim)
    }
    
}
