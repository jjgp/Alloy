import SwiftUI

public struct Children: View {
    
    public var body: some View {
        let views = self.views
        return ForEach(0..<views.count) {
            views[$0]
        }
    }
    let views: [Element]
    
    init(_ views: [Element]) {
        self.views = views
    }
    
}
