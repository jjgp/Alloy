import JavaScriptCore
import SwiftUI

public struct Element: View {
    
    @objc class Exports: NSObject {
        
        let element: Element
        
        fileprivate init(element: Element) {
            self.element = element
        }
        
    }
    
    public var body: some View {
        erasedBody()
    }
    let erasedBody: () -> AnyView
    
    init<E: ElementSource>(source: E, props: Props) {
        erasedBody = {
            do {
                return AnyView(try source.body(props: props))
            } catch {
                // TODO: improve handling, possibly present error screen in Debug?
                // Have meaningful logs with the default logger.
                return AnyView(EmptyView())
            }
        }
    }
    
}

extension Element {
    
    func exported() -> Exports {
        return Exports(element: self)
    }
    
}
