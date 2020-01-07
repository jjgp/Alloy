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
                return AnyView(Element(error: error))
            }
        }
    }
    
    init(error: Error) {
        erasedBody = {
            #if DEBUG
            return AnyView(Element.erroredView(error))
            #else
            return AnyView(EmptyView())
            #endif
        }
    }
    
    init(error: AlloyError) {
        self.init(error: error as Error)
    }
    
}

extension Element {
    
    private static func erroredView(_ error: Error) -> some View {
        return Text(verbatim: "\(error)")
            .background(Color.red)
            .foregroundColor(.white)
    }
    
}

extension Element {
    
    func exported() -> Exports {
        return Exports(element: self)
    }
    
}
