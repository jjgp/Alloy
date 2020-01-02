import JavaScriptCore
import SwiftUI

@objc protocol AlloyExports : JSExport {
    
    var createElement: CreateElement { get }
    
    typealias CreateElement = @convention(block) (String, [String : Any]?, [ElementExports]?) -> ElementExports
    
}

public class Alloy {
    
    @objc private class Exports: NSObject, AlloyExports {
        
        let createElement: CreateElement = { type, props, children in
            return Element.createExports(type: type,
                                         props: props,
                                         children: children)
        }
        
    }
    
    public let context: JSContext
    let sourceRegistry: [String : AnyElementSource]
    
    public init(script: String,
                exceptionHandler: @escaping (JSContext?, JSValue?) -> Void = Alloy.defaultExceptionHandler,
                logger: @escaping Logger = Alloy.defaultLogger,
                sources: [AnyElementSourceConvertible] = Alloy.defaultSources) {
        sourceRegistry = Dictionary(uniqueKeysWithValues: sources.map { $0.asAnyElementSource}.map { ($0.type, $0) })
        
        context = JSContext()
        context.exceptionHandler = Alloy.defaultExceptionHandler
        context.setObject(Exports(), forKeyedSubscript: "Alloy" as NSString)
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
    
    static let defaultSources: [AnyElementSourceConvertible] = [
        HStackSource(),
        TextSource(),
        VStackSource()
    ]
    
}

// MARK:- Body creation

public extension Alloy {
    
    private func inflate(description: ElementExports) -> Element {
        let source: AnyElementSource! = sourceRegistry[description.type]
        var props = description.props
        if props != nil, let children = description.children?.compactMap({
            inflate(description: $0)
        }) {
            props?["children"] = Children(children)
        }
        return Element(source: source,
                       props: Props(props))
    }
    
    var body: some View {
        let body = context.objectForKeyedSubscript("body")
        let description = body?.call(withArguments: nil)?.toObject() as! ElementExports
        return inflate(description: description)
    }
    
}
