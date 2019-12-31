import JavaScriptCore

@objc protocol ElementExports: JSExport {
    
    var children: [ElementExports]? { get set }
    var props: [String : Any]? { get set }
    var type: String { get set }
    
}

class Element: NSObject, ElementExports {
    
    dynamic var children: [ElementExports]?
    dynamic var props: [String : Any]?
    dynamic var type: String
    
    required init(type: String,
                  props: [String : Any]?,
                  children: [ElementExports]?) {
        self.type = type
        self.props = props
        self.children = children
    }
    
}
