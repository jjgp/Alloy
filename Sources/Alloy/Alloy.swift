import JavaScriptCore
import SwiftUI

// MARK:- Public typealias

public typealias ViewResolver = (String, Props?, [AnyView]) throws -> AnyView?

// MARK:- Alloy JSExport

@objc protocol AlloyExports: JSExport {
    
    typealias CreateElement = @convention(block) (String, [String: Any]?, [String]?) -> String
    
    var createElement: CreateElement { get }
    
}

// MARK:- Alloy implementation

@objc public class Alloy: NSObject, AlloyExports {
    
    class Element: Identifiable {
        
        let id = UUID().uuidString
        let type: String
        let props: Props?
        let children: [String]
        
        init(type: String, props: Props?, children: [Identifier]) {
            self.type = type
            self.props = props
            self.children = children
        }
        
    }
    
    public typealias Logger = @convention(block) (String) -> Void
    typealias Identifier = String
    
    lazy var createElement: CreateElement = { [weak self] type, props, children in
        let element = Element(type: type, props: Props(props), children: children ?? [])
        self?.elements[element.id] = element
        return element.id
    }
    let context: JSContext
    var elements = [Identifier: Element]()
    lazy var rootElementIdentifier: Identifier! = {
        let build = context.objectForKeyedSubscript("body")
        return build?.call(withArguments: nil)?.toString()
    }()
    let viewResolvers: [ViewResolver]
    
    public init?(script: String,
                 exceptionHandler: @escaping (JSContext?, JSValue?) -> Void = Alloy.defaultExceptionHandler,
                 logger: @escaping Logger = Alloy.defaultLogger,
                 viewResolvers: [ViewResolver] = [defaultViewResolver]) {
        context = JSContext()
        self.viewResolvers = viewResolvers
        
        super.init()
        
        context.exceptionHandler = Alloy.defaultExceptionHandler
        context.setObject(self, forKeyedSubscript: "Alloy" as NSString)
        context.objectForKeyedSubscript("Alloy" as NSString)?.setValue(logger, forProperty: "log")
        context.evaluateScript(script)
    }
    
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
    
}

public let defaultViewResolver: ViewResolver = { type, props, children in
    switch type {
    case "Text":
        return try textResolver(type, props, children)
    case "VStack":
        return try vstackResolver(type, props, children)
    default:
        return nil
    }
}

let textResolver: ViewResolver = { type, props, children in
    let verbatim: String = props?.verbatim?.stringValue ?? ""
    return AnyView(Text(verbatim: verbatim))
}

let vstackResolver: ViewResolver = { type, props, children in
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
    
    return AnyView(VStack(alignment: alignment, spacing: spacing) {
        ForEach(0..<children.count) {
            children[$0]
        }
    })
}

// MARK:- Body creation

public extension Alloy {
    
    func inflateElements(by id: String) -> AnyView {
        let element = elements[id]!
        return try! defaultViewResolver(element.type, element.props, element.children.map({
            self.inflateElements(by: $0)
        }))!
    }
    
    func body() throws -> some View {
        inflateElements(by: rootElementIdentifier)
    }
    
}
