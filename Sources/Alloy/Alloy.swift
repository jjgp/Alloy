import JavaScriptCore
import SwiftUI

// MARK:- Alloy JSExports

@objc protocol AlloyExports : JSExport {
    
    var createElement: CreateElement { get }
    
    typealias CreateElement = @convention(block) (String, [String : Any]?, [ElementExports]?) -> ElementExports
    
}

// MARK:- Alloy implementation

@objc public class Alloy : NSObject, AlloyExports {
    
    let createElement: CreateElement = { type, props, children in
        return Element(type: type,
                       props: props,
                       children: children)
    }
    let soluteRegistry: [String : AlloySolute]
    public let context: JSContext
    
    public init?(script: String,
                 exceptionHandler: @escaping (JSContext?, JSValue?) -> Void = Alloy.defaultExceptionHandler,
                 logger: @escaping Logger = Alloy.defaultLogger,
                 solutes: [AlloySolute] = Alloy.defaultSolutes) {
        context = JSContext()
        soluteRegistry = Dictionary(uniqueKeysWithValues: solutes.map { ($0.type, $0) })
        
        super.init()
        
        context.exceptionHandler = Alloy.defaultExceptionHandler
        context.setObject(self, forKeyedSubscript: "Alloy" as NSString)
        context.objectForKeyedSubscript("Alloy" as NSString)?.setValue(logger, forProperty: "log")
        context.evaluateScript(script)
    }
    
    public typealias Logger = @convention(block) (String) -> Void
    typealias Identifier = String
    
}

// MARK:- Default implementations

public extension Alloy {
    
    static let defaultExceptionHandler: (JSContext?, JSValue?) -> Void = { context, exception in
        Alloy.defaultLogger(exception!.toString()!)
    }
    
    static let defaultLogger: Logger = {
        // TODO: use os.log?
        print($0)
    }
    
    static let defaultSolutes: [AlloySolute] = [
        .hstack,
        .text,
        .vstack
    ]
    
}

// MARK:- Body creation

public extension Alloy {
    
    private func inflate(element: ElementExports) -> AlloyView {
        let solute: AlloySolute! = soluteRegistry[element.type]
        return AlloyView(solute: solute,
                         props: Props(element.props),
                         children: element.children?.compactMap({
                            inflate(element: $0)
                         }) ?? [])
    }
    
    func body() throws -> some View {
        let body = context.objectForKeyedSubscript("body")
        let element = body?.call(withArguments: nil)?.toObject() as! ElementExports
        return inflate(element: element)
    }
    
}

public struct AlloyView: View {
    
    public var body: some View {
        solute.body(props, children)
    }
    
    let children: [AlloyView]?
    let props: Props?
    let solute: AlloySolute
    
    public init(solute: AlloySolute, props: Props?, children: [AlloyView]) {
        self.solute = solute
        self.props = props
        self.children = children
    }
    
}

public struct AlloySolute {
    
    let body: (Props?, [AlloyView]?) -> AnyView
    let type: String
    
    public init<V>(type: String, _ body: @escaping (Props?) -> V) where V: View {
        self.body = { props, _ in
            // TODO: assertion on _ (children)
            AnyView(body(props))
        }
        self.type = type
        
    }
    
    public init<V>(type: String, _ body: @escaping (Props?, [AlloyView]?) -> V) where V: View {
        self.body = { props, children in
            AnyView(body(props, children))
        }
        self.type = type
    }
    
}

extension AlloySolute {
    
    static var hstack: AlloySolute {
        func solute(props: Props?, children: [AlloyView]?) -> some View {
            let children = children ?? []
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
                ForEach(0..<children.count) {
                    children[$0]
                }
            }
        }
        
        return AlloySolute(type: "HStack", solute)
    }
    
    static var text: AlloySolute {
        func solute(props: Props?, children: [AlloyView]?) -> some View {
            let verbatim: String = props?.verbatim?.stringValue ?? ""
            return Text(verbatim: verbatim)
        }
        
        return AlloySolute(type: "Text", solute)
    }
    
    static var vstack: AlloySolute {
        func solute(props: Props?, children: [AlloyView]?) -> some View {
            let children = children ?? []
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
                ForEach(0..<children.count) {
                    children[$0]
                }
            }
        }
        
        return AlloySolute(type: "VStack", solute)
    }
    
}
