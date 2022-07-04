/**
TODO
    Rename file
*/

internal extension CInt {
    
    /// Throws for error codes.
    @inline(__always)
    func sdlThrow(error: SDL2Error, 
                  file: String = #file,
                  function: String = #function,
                  line: UInt = #line) throws {
        
        guard self >= 0 else {
            throw error
        }
    }
}

internal extension Optional {
    
    /// Unwraps optional value, throwing error if nil.
    @inline(__always)
    func sdlThrow(error: SDL2Error, 
                  file: String = #file,
                  function: String = #function,
                  line: UInt = #line) throws -> Wrapped {
        
        guard let value = self else {
            throw error
        }
        return value
    }
}