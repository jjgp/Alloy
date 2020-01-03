import JavaScriptCore
import SwiftUI

@objc protocol ElementExports: JSExport {
    
    var children: [ElementExports]? { get set }
    var props: [String: Any]? { get set }
    var type: String { get set }
    
}

public struct Element: View {
    
    @objc private class Exports: NSObject, ElementExports {
        
        dynamic var children: [ElementExports]?
        dynamic var props: [String: Any]?
        dynamic var type: String
        
        required init(type: String,
                      props: [String: Any]?,
                      children: [ElementExports]?) {
            self.type = type
            self.props = props
            self.children = children
        }
        
    }
    
    public var body: some View {
        bodyErased(props)
    }
    let bodyErased: (Props?) -> AnyView
    let props: Props?
    
    init<E: ElementSource>(source: E, props: Props?) {
        bodyErased = {
            do {
                return AnyView(try source.body(props: $0))
            } catch {
                // TODO: improve handling, possibly present error screen in Debug?
                // Have meaningful logs with the default logger.
                return AnyView(EmptyView())
            }
        }
        self.props = props
    }
    
}

extension Element {
    
    static func createExports(type: String,
                              props: [String: Any]?,
                              children: [ElementExports]?) -> ElementExports {
        return Exports(type: type,
                       props: props,
                       children: children)
    }
    
}
