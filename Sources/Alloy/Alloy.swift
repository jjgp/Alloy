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
    
    let sources: [String: ElementConvertible]
    let context: JSContext
    static let contextObjectKey: NSString = "Alloy"
    
    public init(script: String,
                extensions: [ContextExtension] = .defaultExtensions,
                sources: [ElementConvertible] = .defaultSources) {
        self.sources = Dictionary(uniqueKeysWithValues: sources.map { ($0.type, $0) })
        context = JSContext()
        context.setObject(Exports(), forKeyedSubscript: Alloy.contextObjectKey)
        extensions.forEach {
            $0.extension(context)
        }
        context.evaluateScript(script)
    }
    
}

// MARK:- Default initializer arguments

public extension Array where Element == ContextExtension {
    
    static var defaultExtensions: [ContextExtension] {
        [
            .alloyExceptionHandler,
            .alloyLogger
        ]
    }
    
}

public extension Array where Element == ElementConvertible {
    
    static var defaultSources: [ElementConvertible] {
        [
            HStackSource(),
            TextSource(),
            VStackSource()
        ]
    }
    
}

// MARK:- Body creation

public extension Alloy {
    
    var body: some View {
        let body = context.objectForKeyedSubscript("body")
        let exports = body?.call(withArguments: nil)?.toObject() as! ElementExports
        return sourceElement(exports: exports)
    }
    
    private func sourceElement(exports: ElementExports) -> Element {
        let source: ElementConvertible! = sources[exports.type]
        var props = exports.props
        if props != nil, let children = exports.children?.compactMap({
            sourceElement(exports: $0)
        }) {
            props?["children"] = Children(children)
        }
        return source.toElement(passing: Props(props))
    }
    
}
