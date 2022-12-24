import CGL

func loadGLFunction<T>(_ name: String) -> T {
#if os(macOS)
    return unsafeBitCast(dlsym(RTLD_DEFAULT, name), to: T.self)
#elseif os(Linux)
    return unsafeBitCast(glXGetProcAddress(name), to: T.self)
#elseif os(Windows)
    return unsafeBitCast(wglGetProcAddress(name), to: T.self)
#endif
}

/**
 This may be necessary to provide openGL-Functions at compile-time (normally they are loaded at runtime via GLEW, but Swift 
 can not handle the C-macro-metaprogramming glew is doing)
 see https://forums.swift.org/t/swift-can-t-compile-code-with-opengl-function-pointers/5551

 TODO: How can we find out when we accidently call [loadGLFunction] with a wrong function name?
 TODO: This will get very tedious
*/
enum GL {
    static let glCreateProgram: @convention(c) () -> GLuint = loadGLFunction("glCreateProgram")
    static let glDeleteProgram: @convention(c) (GLuint) -> Void = loadGLFunction("glDeleteProgram")  
    // TODO: GL-Specification wants an GLEnum, but Swift needs an Int32 here ... 
    static let glCreateShader: @convention(c) (Int32) -> GLuint = loadGLFunction("glCreateShader")
    static let glDeleteShader: @convention(c) (GLuint) -> Void = loadGLFunction("glDeleteShader")
    static let glUseProgram: @convention(c) (GLuint) -> Void = loadGLFunction("glUseProgram")
}

// TODO: This might get tedious ...
enum GLError: Error {
    case failedToCreateShaderProgram
    case failedToCreateShader
}