import CGL

final class Shader {

    private let programID: GLuint 
    private let vertexID: GLuint 
    private let fragmentID: GLuint      

    // TODO: Second initializer with geometry and tesselation shader
    init(vertexShaderPath: String, fragmentShaderPath: String) throws {

        programID = try GL.glCreateProgram()
            .succeedOrThrow(error: .failedToCreateShaderProgram)
        vertexID = try GL.glCreateShader(GL_VERTEX_SHADER)
            .succeedOrThrow(error: .failedToCreateShader)
        fragmentID = try GL.glCreateShader(GL_FRAGMENT_SHADER)
            .succeedOrThrow(error: .failedToCreateShader)

        print("programID: \(programID)")
        print("vertexID: \(vertexID)")
        print("fragmentID: \(fragmentID)")
        
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

    /// disable this shader when drawing
    func off() {
        GL.glUseProgram(0)
    }

    

}

