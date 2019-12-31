import XCTest
@testable import Alloy

let alloyScript = #"""
function body() {
  Alloy.log('foobar');
  return Alloy.createElement(
    'VStack',
    { alignment: 'center', spacing: 25.3 },
    [
      Alloy.createElement('Text', { verbatim: 'Foobar' }, null),
      Alloy.createElement('Text', { verbatim: 'Barbaz' }, null),
      Alloy.createElement('Text', { verbatim: 'Quzquix' }, null),
      Alloy.createElement('Text', { verbatim: 'Barfoo' }, null),
    ]
  );
}
"""#

final class AlloyTests: XCTestCase {
    
    func testBodyIsNotNil() {
        let element = Alloy(script: alloyScript).body as! Element
        XCTAssertNotNil(element.body)
    }

    static var allTests = [
        ("testBodyIsNotNil", testBodyIsNotNil),
    ]
    
}
