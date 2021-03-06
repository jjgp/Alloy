import JavaScriptCore

public struct ContextExtension {
    
    let `extension`: (JSContext) -> Void
    
    public init(_ extension: @escaping (JSContext) -> Void) {
        self.extension = `extension`
    }
    
}

public extension ContextExtension {
    
    static var alloyExceptionHandler: ContextExtension {
        ContextExtension {
            $0.exceptionHandler = { context, exception in
                ContextExtension.defaultLogger(exception!.toString()!)
            }
        }
    }
    
    static var alloyLogger: ContextExtension {
        ContextExtension {
            // TODO: extract logger out into its own entity and reference it here
            let logger: @convention(block) (String) -> Void = {
                ContextExtension.defaultLogger($0)
            }
            // TODO: this seems pretty indirect way to set on Alloy object...
            $0.objectForKeyedSubscript(Alloy.contextObjectKey)?.setValue(logger, forProperty: "log")
        }
    }
    
    private static func defaultLogger(_ message: String) {
        print(message)
    }
    
}
