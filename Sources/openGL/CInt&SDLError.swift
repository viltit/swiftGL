
import CGL

/**
    Extensions that are checking different kinds of integers. OpenGL often gives an integer as a pointer
    to a resource back from a function (ie, glCreateProgram(), glCreateShader(), ...). These extension make
    it easier to check if OpenGL indeed did create a resource or not.

    TODO: Make use of the file, function and line stuff
    TODO: Call all functions [succeedOrThrow]
    TODO: Rename file
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

internal extension GLuint {

    /// Checks that a GLint is neither zero, nor max or min, and throws an error if not
    /// TODO: Make sure we do not copy [self] here
    @inline(__always)
    func succeedOrThrow(error: GLError,
                        file: String = #file,
                        function: String = #function,
                        line: UInt = #line) throws -> GLuint {
        guard self != 0, self != GLint.max, self != GLint.min else {
            throw error
        }
        return self
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