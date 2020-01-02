import SwiftUI

public protocol ElementSource: ElementConvertible {
    
    associatedtype Body: View
    
    var type: String { get }
    
    func body(props: Props?) -> Self.Body
    
}

public protocol ElementConvertible {
    
    var type: String { get }
    
    func toElement(passing props: Props?) -> Element
    
}

public extension ElementSource {
    
    func toElement(passing props: Props?) -> Element {
        return .init(source: self, props: props)
    }
    
}

public struct VStackSource: ElementSource {
    
    public let type = "VStack"
    
    public func body(props: Props?) -> some View {
        let alignment = props?.alignment?.stringValue
            .flatMap { HorizontalAlignment.represented(by: $0) }
            ?? .center
        let spacing = CGFloat(truncating: props?.spacing?.numberValue ?? 0)
        
        return VStack(alignment: alignment, spacing: spacing) {
            props?.children?.childrenValue ?? .emptyChildren
        }
    }
    
}

public struct HStackSource: ElementSource {
    
    public let type = "HStack"
    
    public func body(props: Props?) -> some View {
        let alignment = props?.alignment?.stringValue
            .flatMap { VerticalAlignment.represented(by: $0) }
            ?? .center
        let spacing = CGFloat(truncating: props?.spacing?.numberValue ?? 0)
        
        return HStack(alignment: alignment, spacing: spacing) {
            props?.children?.childrenValue ?? .emptyChildren
        }
    }
    
}

public struct TextSource: ElementSource {
    
    public let type = "Text"
    
    public func body(props: Props?) -> some View {
        let verbatim = props?.verbatim?.stringValue ?? ""
        return Text(verbatim: verbatim)
    }
    
}
