import JavaScriptCore
import SwiftUI

@objc protocol AlloyExports: JSExport {
    
    var createElement: CreateElement { get }
    
    typealias CreateElement = @convention(block) (String, JSValue?) -> Element.Exports
    
}

public struct Alloy: View {
    
    @objc fileprivate class Exports: NSObject, AlloyExports {
        
        let createElement: CreateElement
        
        init(sources: [ElementConvertible]) {
            createElement = Self.createElement(sources: sources)
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

// MARK:- 

private extension Alloy.Exports {
    
    static func createElement(sources: [ElementConvertible]) -> CreateElement {
        let sources = Dictionary(uniqueKeysWithValues: sources.map { ($0.type, $0) })
        return { type, props in
            guard let source = sources[type] else {
                return Element(error: .source("Undefined source type (\(type)) in Alloy.createElement")).exported()
            }
            
            return source.toElement(passing: Props(props)).exported()
        }
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
            return Element(error: .exports("body function did not create Element.Exports"))
        }
        return exports.element
    }
    
}
