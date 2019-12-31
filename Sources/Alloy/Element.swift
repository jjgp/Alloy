import SwiftUI

public struct Element: View {
    
    public var body: some View {
        source.body(props: props)
    }
    
    let props: Props?
    let source: AnyElementSource
    
    public init(source: AnyElementSource, props: Props?) {
        self.props = props
        self.source = source
    }
    
}
