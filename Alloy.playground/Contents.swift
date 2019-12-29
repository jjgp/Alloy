import Alloy
import SwiftUI
import PlaygroundSupport

let alloy = Alloy(script: "function body() { Alloy.log('foobar'); return Alloy.createElement('View', {foobar: 'bazquux'}, [Alloy.createElement('Text', {quux: 'foobar'}, null)]);}")

let hc = UIHostingController(rootView: try! alloy!.body())

PlaygroundPage.current.liveView = hc
