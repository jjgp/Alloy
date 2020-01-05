import JavaScriptCore

@dynamicCallable
@dynamicMemberLookup
public enum Props {
    
    case none
    case managedValue(JSManagedValue)
    
    init(_ value: Any?) {
        if value is JSManagedValue {
            self = .managedValue(value as! JSManagedValue)
        } else if value is JSValue {
            self = .managedValue(JSManagedValue(value: value as? JSValue))
        } else {
            self = .none
        }
    }
    
}

public extension Props {
    
    func toChildren() -> Children? {
        guard let exports = underlayingValue?.toObject() as? [Element.Exports] else {
            return nil
        }
        let elements = exports.map({ $0.element })
        return Children(elements)
    }
    
    func toNumber() -> NSNumber? {
        guard let number = underlayingValue?.toNumber() else {
            return nil
        }
        return number
    }
    
    func toString() -> String? {
        guard let stringValue = underlayingValue?.toString() else {
            return nil
        }
        return stringValue
    }
    
    private var underlayingValue: JSValue? {
        guard case let .managedValue(managedValue) = self else {
            return nil
        }
        return managedValue.value
    }
    
}

// MARK:- @dynamicCallable

public extension Props {
    
    func dynamicallyCall(withArguments: [Any]) -> Props {
        return Props(underlayingValue?.call(withArguments: withArguments))
    }
    
}

// MARK:- @dynamicMemberLookup

public extension Props {
    
    subscript(dynamicMember member: String) -> Props {
        return Props(underlayingValue?.forProperty(member))
    }
    
}
