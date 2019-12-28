import XCTest
@testable import Alloy

let alloyScript = #"""
function body() {
    Alloy.log('foobar');
    return Alloy.createElement(
        'View',
        {foobar: 'bazquux'},
        [Alloy.createElement('Text', {quux: 'foobar'}, null)]
    );
}
"""#

final class AlloyTests: XCTestCase {
    
    func testBodyIsNotNil() {
        let body = try? Alloy(script: alloyScript)?.body()
        XCTAssertNotNil(body)
    }

    static var allTests = [
        ("testBodyIsNotNil", testBodyIsNotNil),
    ]
    
}
