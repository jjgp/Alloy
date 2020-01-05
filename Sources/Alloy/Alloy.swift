import JavaScriptCore
import SwiftUI

@objc protocol AlloyExports: JSExport {
    
    var createElement: CreateElement { get }
    
    typealias CreateElement = @convention(block) (String, JSValue?) -> Element.Exports
    
}

public struct Alloy: View {
    
    @objc private class Exports: NSObject, AlloyExports {
        
        let createElement: CreateElement
        
        init(sources: [ElementConvertible]) {
            let sources = Dictionary(uniqueKeysWithValues: sources.map { ($0.type, $0) })
            createElement = { type, props in
                return sources[type]?.toElement(passing: Props(props)).exported()
                    /* TODO: make ElementSourceError more generic like AlloyError struct? */
                    ?? Element(error: ElementSourceError.undefinedSourceError()).exported()
            }
        }
        
    }
    
    let context: JSContext
    static let contextObjectKey: NSString = "Alloy"
    
    public init(script: String,
                extensions: [ContextExtension] = .defaultExtensions,
                sources: [ElementConvertible] = .defaultSources) {
        context = JSContext()
        context.setObject(Exports(sources: sources), forKeyedSubscript: Alloy.contextObjectKey)
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
            ButtonSource(),
            HStackSource(),
            TextSource(),
            VStackSource()
        ]
    }
    
}

// MARK:- Body creation

public extension Alloy {
    
    var body: some View {
        let bodyScript = context.objectForKeyedSubscript("body")
        let exports = bodyScript?.call(withArguments: nil)?.toObject() as? Element.Exports
        // TODO: Should be a fatal error? or have user pass backup view?
        return exports?.element
            /* TODO: This is the wrong type of error for now */
            ?? Element(error: ElementSourceError.undefinedSourceError())
    }
    
}
