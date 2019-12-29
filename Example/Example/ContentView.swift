//
//  ContentView.swift
//  Example
//
//  Created by Jason Prasad on 12/28/19.
//  Copyright © 2019 Alloy. All rights reserved.
//

import Alloy
import SwiftUI

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

struct ContentView: View {
    
    var body: some View {
        let alloy = Alloy(script: alloyScript)
        return try! alloy!.body()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}
