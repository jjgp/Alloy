import XCTest
import SwiftUI
@testable import Alloy

let alloyScript = #"""
function body() {
  let element = Alloy.createElement('Text', { verbatim: 'Ann Arbor' })
  Alloy.log(element);
  return Alloy.createElement(
    'VStack',
    {
      alignment: 'leading',
      spacing: 10.0,
      children: [
        element,
        Alloy.createElement('Text', { verbatim: 'Detroit' }),
        Alloy.createElement(
          'HStack',
          {
            alignment: 'trailing',
            spacing: 5.0,
            children: [
              Alloy.createElement('Text', { verbatim: 'DIA' }),
              Alloy.createElement('Text', { verbatim: 'RenCen' }),
              Alloy.createElement('Text', { verbatim: 'StockX' }),
            ],
          },
        ),
        Alloy.createElement('Text', { verbatim: 'Lansing' }),
        Alloy.createElement('Text', { verbatim: 'Royal Oak' }),
      ],
    },
  );
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

