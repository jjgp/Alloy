import JavaScriptCore
import SwiftUI

// MARK:- Public typealias

public typealias Props = [String: Any]

public typealias ViewResolver = (String, Props?, [AnyView]?) throws -> AnyView?

// MARK:- Alloy JSExport

@objc protocol AlloyExports: JSExport {
    
    typealias Identifier = String
    typealias CreateElement = @convention(block) (String, Props?, [Identifier]?) -> Identifier
    
    var createElement: CreateElement { get }
    
}

// MARK:- Alloy implementation

@objc public class Alloy: NSObject, AlloyExports {
    
    class Element {
        
        let identifier = UUID().uuidString
        let type: String
        let props: Props?
        let children: [Identifier]?
        
        init(type: String, props: Props?, children: [Identifier]?) {
            self.type = type
            self.props = props
            self.children = children
        }
        
    }
    
    public typealias Logger = @convention(block) (String) -> Void
    
    lazy var createElement: CreateElement = { [weak self] type, props, children in
        let element = Element(type: type, props: props, children: children)
        self?.elements[element.identifier] = element
        return element.identifier
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
    let verbatim: String = props?["verbatim"] as? String ?? ""
    return AnyView(Text(verbatim: verbatim))
}

let vstackResolver: ViewResolver = { type, props, children in
    let alignment: HorizontalAlignment = props?["alignment"] as? HorizontalAlignment ?? .center
    let spacing: CGFloat? = props?["spacing"] as? CGFloat
    return AnyView(VStack(alignment: alignment, spacing: spacing) {
        Text("Hello")
        Text("Hello")
        Text("Hello")
    })
}

// MARK:- Body creation

extension Alloy {
    
    func body() throws -> some View {
        try viewResolvers.first!("VStack", nil, nil)
    }
    
}
