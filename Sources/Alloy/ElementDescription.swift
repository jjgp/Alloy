import JavaScriptCore

@objc protocol ElementDescriptionExports: JSExport {
    
    var children: [ElementDescriptionExports]? { get set }
    var props: [String : Any]? { get set }
    var type: String { get set }
    
}

class ElementDescription: NSObject, ElementDescriptionExports {
    
    dynamic var children: [ElementDescriptionExports]?
    dynamic var props: [String : Any]?
    dynamic var type: String
    
    required init(type: String,
                  props: [String : Any]?,
                  children: [ElementDescriptionExports]?) {
        self.type = type
        self.props = props
        self.children = children
    }
    
}
