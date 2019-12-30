import JavaScriptCore
import SwiftUI

// MARK:- Public typealias

public typealias ViewResolver = (String, Props?, [AnyView]) throws -> AnyView?

// MARK:- Alloy JSExports

@objc protocol AlloyExports: JSExport {
    
    typealias CreateElement = @convention(block) (String, [String : Any]?, [ElementExports]?) -> ElementExports
    
    var createElement: CreateElement { get }
    
}

@objc protocol ElementExports: JSExport {
    
    var children: [ElementExports]? { get set }
    var props: [String : Any]? { get set }
    var type: String { get set }
    
}

// MARK:- Alloy implementation

@objc public class Alloy: NSObject, AlloyExports {
    
    let createElement: CreateElement = { type, props, children in
        return Element(type: type,
                       props: props,
                       children: children)
    }
    let viewResolvers: [ViewResolver]
    public let context: JSContext
    
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
    
    public typealias Logger = @convention(block) (String) -> Void
    typealias Identifier = String
    
}

class Element: NSObject, ElementExports {
    
    dynamic var children: [ElementExports]?
    dynamic var props: [String : Any]?
    dynamic var type: String
    
    required init(type: String,
                  props: [String : Any]?,
                  children: [ElementExports]?) {
        self.type = type
        self.props = props
        self.children = children
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
    
    private func inflate(element: ElementExports) -> AnyView {
        return try! defaultViewResolver(element.type,
                                        Props(element.props),
                                        element.children?.compactMap({
                                            inflate(element: $0)
                                        }) ?? [])!
    }
    
    func body() throws -> some View {
        let build = context.objectForKeyedSubscript("body")
        let element = build?.call(withArguments: nil)?.toObject() as! ElementExports
        return inflate(element: element)
    }
    
}

public struct AlloyView {}
