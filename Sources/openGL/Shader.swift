import CGL
import Foundation

// TODO: Look at https://stackoverflow.com/questions/24050344/convert-swift-cchar-array-into-a-string

final class Shader {

    let name: String  
    
    private let programID: GLuint 
    private let vertexID: GLuint 
    private let fragmentID: GLuint    

    // TODO: Second initializer with geometry and tesselation shader
    init(name: String, sourceVertexCode: String, sourceFragmentCode: String) throws {

        self.name = name
        programID = try GL.glCreateProgram()
            .succeedOrThrow(error: .failedToCreateShaderProgram)
        vertexID = try GL.glCreateShader(GL_VERTEX_SHADER)
            .succeedOrThrow(error: .failedToCreateShader)
        fragmentID = try GL.glCreateShader(GL_FRAGMENT_SHADER)
            .succeedOrThrow(error: .failedToCreateShader)
        
        try compile(source: sourceVertexCode, shader: vertexID)
        try compile(source: sourceFragmentCode, shader: fragmentID)
        try link()
    }

    deinit {
        GL.glDeleteProgram(programID)
        GL.glDeleteShader(vertexID)
        GL.glDeleteShader(fragmentID)
    }

    /// enable this shader when drawing 
    func on() {
        GL.glUseProgram(programID)
    }

    /// disable this shader when drawing. Probably optional to call, but considered best practise...
    func off() {
        GL.glUseProgram(0)
    }

    /// return an identifier to a shaders uniform variable
    func uniform(name: String) throws -> GLint {
        var cStr = name.cString(using: String.Encoding.ascii)
        let location = GL.glGetUniformLocation(programID, cStr)
        guard location != -1 else {
            throw GLError.uniformNotFound(uniform: name, shaderName: name)
        }
        return location
    } 

    /// compile shader source code
    private func compile(source code: String, shader id: GLuint) throws {
        
        // do weird casting from source code string to char** and compile shader
        // TODO: Compiler warns of dangling pointer
        var cStr = code.cString(using: String.Encoding.ascii)
        guard var codePtr = UnsafeMutablePointer(mutating: cStr) else {
            fatalError(/* TODO */)
        }
        GL.glShaderSource(id, 1, &codePtr, nil)
        GL.glCompileShader(id)
        
        // check for compile status
        var compileStatus: GLint = 0
        GL.glGetShaderiv(id, GL_COMPILE_STATUS, &compileStatus)

        // something went wrong? Fetch error log and throw
        guard compileStatus == GL_TRUE else {
            
            var length: GLint = 0
            GL.glGetShaderiv(id, GL_INFO_LOG_LENGTH, &length)
            var buffer = [ CChar ](repeating: 0, count: Int(length))
            GL.glGetShaderInfoLog(id, length, &length, &buffer)
            throw GLError.shaderCompileError(log: String(cString: buffer), shaderName: name)
        }
    }

    private func link() throws {
        
        // link shaders into program
        GL.glAttachShader(programID, vertexID)
        GL.glAttachShader(programID, fragmentID)
        GL.glLinkProgram(programID)

        // check link status
        var linkStatus: GLint = 0
        GL.glGetProgramiv(programID, GL_LINK_STATUS, &linkStatus)

        // something went wrong? fetch error log and throw
        guard linkStatus == GL_TRUE else {
            
            var length: GLint = 0
            GL.glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &length)
            var buffer = [ CChar ](repeating: 0, count: Int(length))
            GL.glGetProgramInfoLog(programID, length, &length, &buffer)
            throw GLError.shaderLinkingError(log: String(cString: buffer), shaderName: name)  
        }
    }
}

