import Alloy
import SwiftUI
import PlaygroundSupport

let script: String! = Bundle.main.path(forResource: "body", ofType: "js")
    .flatMap { FileManager.default.contents(atPath: $0) }
    .flatMap { String(data: $0, encoding: .utf8) }
let hc = UIHostingController(rootView: Alloy(script: script))

PlaygroundPage.current.liveView = hc
