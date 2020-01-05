import XCTest
import SwiftUI
@testable import Alloy

let alloyScript = #"""
function body() {
  return Alloy.createElement('Function', () => Alloy.createElement('Text', { verbatim: 'Function' }));
}
"""#

final class AlloyTests: XCTestCase {
    
    func testBodyIsNotNil() {
        let element = Alloy(script: alloyScript).body as! Element
        let hc = UIHostingController(rootView: element)
        _ = hc.view
        XCTAssertNotNil(element.body)
    }

    static var allTests = [
        ("testBodyIsNotNil", testBodyIsNotNil),
    ]
    
}

