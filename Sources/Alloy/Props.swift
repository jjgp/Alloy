import Foundation

/// Inspiration: https://github.com/apple/swift-evolution/blob/master/proposals/0195-dynamic-member-lookup.md
@dynamicMemberLookup
public enum Props {
    
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([Any])
    case dictionary([String: Any?])
    
    init?(_ value: Any?) {
        switch value {
        case is Int:
            self = .int(value as! Int)
        case is Bool:
            self = .bool(value as! Bool)
        case is Double:
            self = .double(value as! Double)
        case is String:
            self = .string(value as! String)
        case is [Any]:
            self = .array(value as! [Any])
        case is [String: Any]:
            self = .dictionary(value as! [String: Any?])
        default:
            return nil
        }
    }
    
}

public extension Props {
    
    subscript(index: Int) -> Props? {
        if case .array(let arr) = self, index < arr.count {
            return Props(arr[index])
        }
        return nil
    }
    
    subscript(key: String) -> Props? {
        return dictionaryValue(for: key)
    }
    
    subscript(dynamicMember member: String) -> Props? {
        return dictionaryValue(for: member)
    }
    
    private func dictionaryValue(for key: String) -> Props? {
        guard case let .dictionary(dict) = self else {
            return nil
        }
        
        if dict.keys.contains(key) {
            return Props(dict[key, default: nil]) ?? .null
        } else {
            return nil
        }
    }
    
}

public extension Props {
    
    var isNull: Bool {
        if case .null = self {
            return true
        } else {
            return false
        }
    }
    
    var boolValue: Bool? {
        if case .bool(let bool) = self {
            return bool
        }
        return nil
    }
    
    var intValue: Int? {
        if case .int(let int) = self {
            return int
        }
        return nil
    }
    
    var doubleValue: Double? {
        if case .double(let double) = self {
            return double
        }
        return nil
    }
    
    var stringValue: String? {
        if case .string(let str) = self {
            return str
        }
        return nil
    }
    
    var arrayValue: [Any]? {
        if case .array(let arr) = self {
            return arr
        }
        return nil
    }
    
    var arrayOfJSON: [Props]? {
        return arrayValue?.compactMap { Props($0) }
    }
    
    func array<T>(of: T) -> [T]? {
        return arrayValue?.compactMap { Props($0 as? T) as? T }
    }
    
    var dictionaryValue: [String: Any?]? {
        if case .dictionary(let dict) = self {
            return dict
        }
        return nil
    }
    
    var dictionaryOfJSON: [String: Props]? {
        if let keysWithValues = dictionaryValue?.compactMap({ ($0, Props($1)) as? (String, Props) }) {
            return Dictionary(uniqueKeysWithValues: keysWithValues)
        }
        return nil
    }
    
    func dictionary<T>(of: T) -> [String: T]? {
        if let keysWithValues = dictionaryValue?.compactMap({ ($0, $1) as? (String, T) }) {
            return Dictionary(uniqueKeysWithValues: keysWithValues)
        }
        return nil
    }
    
}
