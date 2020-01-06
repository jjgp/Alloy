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
                #if DEBUG
                return AnyView(Element.erroredView(error))
                #else
                fatalError("source with type \(source.type) threw \(error)")
                #endif
            }
        }
    }
    
    init(error: Error) {
        erasedBody = {
            AnyView(Element.erroredView(error))
        }
    }
    
}

extension Element {
    
    static func erroredView(_ error: Error) -> some View {
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
