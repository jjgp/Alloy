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
                    ?? Element(error: AlloyError.source("Undefined source type (\(type)) in Alloy.createElement")).exported()
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
        guard let exports = bodyScript?.call(withArguments: nil)?.toObject() as? Element.Exports else {
            let errorMessage = "body function did not create Element.Exports"
            #if DEBUG
            return Element(error: AlloyError.exports(errorMessage))
            #else
            fatalError(errorMessage)
            #endif
        }
        return exports.element
    }
    
}
