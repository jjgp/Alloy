import JavaScriptCore

@dynamicCallable
@dynamicMemberLookup
public enum Props {
    
    case none
    case value(JSValue)
    
    init(_ value: Any?) {
        if value is JSValue {
            self = .value(value as! JSValue)
        } else {
            self = .none
        }
    }
    
}

public extension Props {
    
    var underlyingValue: JSValue? {
        if case let .value(value) = self {
            return value
        } else {
            return nil
        }
    }
    
}

public extension Props {
    
    subscript(dynamicMember member: String) -> Props {
        guard case let .value(value) = self else {
            return .none
        }
        
        return Props(value.forProperty(member))
    }
    
}

public extension Props {
    
    func dynamicallyCall(withArguments: [Any]) -> Props {
        guard case let .value(value) = self else {
            return .none
        }
        
        return Props(value.call(withArguments: withArguments))
    }
    
}
