import Alloy
import SwiftUI
import PlaygroundSupport

// NOTE: Swift playground does not support #""" """# strings with special
// characters like (){}

let script = "function body() {" +
"Alloy.log('foobar');" +
"return Alloy.createElement('View', {foobar: 'bazquux'}, [Alloy.createElement('Text', {quux: 'foobar'}, null)]);" +
"}"

let alloy = Alloy(script: script)

let hc = UIHostingController(rootView: try! alloy!.body())

PlaygroundPage.current.liveView = hc
