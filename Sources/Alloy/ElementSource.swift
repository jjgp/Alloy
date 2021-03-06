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
            throw AlloyError.children("\(type) expects children")
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
            throw AlloyError.children("\(type) expects children")
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
