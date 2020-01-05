import Alloy
import SwiftUI
import PlaygroundSupport

let script: String! = Bundle.main.path(forResource: "body", ofType: "js")
    .flatMap { FileManager.default.contents(atPath: $0) }
    .flatMap { String(data: $0, encoding: .utf8) }
let alloy = Alloy(script: script)
let hc = UIHostingController(rootView: alloy.body)

PlaygroundPage.current.liveView = hc
