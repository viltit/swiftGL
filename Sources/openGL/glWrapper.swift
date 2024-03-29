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
    /// Shaders
    static let glCreateProgram: @convention(c) () -> GLuint = loadGLFunction("glCreateProgram")
    static let glDeleteProgram: @convention(c) (GLuint) -> Void = loadGLFunction("glDeleteProgram")  
    // TODO: GL-Specification wants an GLEnum, but Swift needs an Int32 here ... 
    static let glCreateShader: @convention(c) (Int32) -> GLuint = loadGLFunction("glCreateShader")
    static let glDeleteShader: @convention(c) (GLuint) -> Void = loadGLFunction("glDeleteShader")
    static let glUseProgram: @convention(c) (GLuint) -> Void = loadGLFunction("glUseProgram")
    static let glShaderSource: @convention(c) 
         (GLuint, GLsizei, UnsafeMutablePointer<UnsafeMutablePointer<CChar>>?, UnsafePointer<GLint>?) -> ()
        = loadGLFunction("glShaderSource")
    static let glCompileShader: @convention(c) (GLuint) -> Void = loadGLFunction("glCompileShader")
    static let glGetShaderiv: @convention(c) (GLuint, Int32, UnsafeMutablePointer<GLint>) -> Void = loadGLFunction("glGetShaderiv")
    static let glGetShaderInfoLog: @convention(c) (
        GLuint, Int32, UnsafeMutablePointer<Int32>,  UnsafeMutablePointer<CChar>) -> Void = loadGLFunction("glGetShaderInfoLog")
    static let glAttachShader: @convention(c) (GLuint, GLuint) -> Void = loadGLFunction("glAttachShader")
    static let glLinkProgram: @convention(c) (GLuint) -> Void = loadGLFunction("glLinkProgram")
    static let glGetProgramiv: @convention(c) (GLuint, Int32, UnsafeMutablePointer<GLint>) -> Void = loadGLFunction("glGetProgramiv")
    static let glGetProgramInfoLog: @convention(c) (
        GLuint, Int32, UnsafeMutablePointer<Int32>, UnsafeMutablePointer<CChar>) -> Void = loadGLFunction("glGetProgramInfoLog")

    /// drawing commands
    static let glDrawArrays: @convention(c) (Int32, GLint, GLsizei) -> () = loadGLFunction("glDrawArrays")

    /// set uniforms. ... https://manpages.ubuntu.com/manpages/focal/man3/glUniform2i.3G.html ...
    static let glGetUniformLocation: @convention(c) (GLuint, UnsafePointer<CChar>?) -> GLint = loadGLFunction("glGetUniformLocation")
    static let glUniform4f: @convention(c) (GLint, GLfloat, GLfloat, GLfloat, GLfloat) -> () = loadGLFunction("glUniform4f")
    static let glUniformMatrix4fv: @convention(c) (GLint, GLsizei, GLboolean, UnsafePointer<Float>?) -> () = loadGLFunction("glUniformMatrix4fv")

    /// buffers
    /// TODO: Does UnsafeMutableRawPointer work ??
    static let glGenBuffers: @convention(c) (GLsizei, UnsafeMutablePointer<GLuint>) -> () = loadGLFunction("glGenBuffers")
    static let glBindBuffer: @convention(c) (Int32, GLuint) -> () = loadGLFunction("glBindBuffer")
    static let glCreateVertexArrays: @convention(c) (GLsizei, UnsafeMutablePointer<GLuint>) -> () = loadGLFunction("glCreateVertexArrays")
    static let glBindVertexArray: @convention(c) (GLuint) -> () = loadGLFunction("glBindVertexArray")
    static let glBufferData: @convention(c) (Int32, Int32, UnsafeRawPointer?, Int32) -> () = loadGLFunction("glBufferData")
    static let glEnableVertexAttribArray: @convention(c) (GLuint) -> () = loadGLFunction("glEnableVertexAttribArray")
    static let glVertexAttribPointer: @convention(c) (
        GLuint, GLint, Int32, GLboolean, GLsizei, UnsafeRawPointer?) -> () = loadGLFunction("glVertexAttribPointer")
}

// TODO: This might get tedious ...
enum GLError: Error {
    case failedToCreateBuffer
    case failedToCreateShaderProgram
    case failedToCreateShader
    case uniformNotFound(uniform: String, shaderName: String)
    case shaderCompileError(log: String, shaderName: String)
    case shaderLinkingError(log: String, shaderName: String)
}