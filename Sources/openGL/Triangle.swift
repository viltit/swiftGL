
// TODO much later: Base class/ protocol [GLDrawable] ? 
import CGL
import Foundation
import SGLMath

class Triangle {

    /// vertex buffer object, holds the geometry (but could also hold uv-coordinates for textures)
    var vbo: GLuint = 0
    var vao: GLuint = 0
    let numVertices: GLsizei

    // TODO later: Dedicated class / struct [ Transformation ] with methods to rotate, move, scale etc. 
    var modelMatrix = mat4() 

    init() {

        // TODO: Use a struct [Vertex] that also has colors
        // TODO advanced: Make a struct/protocol [Vertex] that can or can not have additional fields 
        var vertices: [ Float ] = [
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0
        ]
        numVertices = 3
    
        // TODO: Make sure vbo is set
        GL.glGenBuffers(1, &vbo)
        if vbo == 0 {
            fatalError()
        }
        GL.glCreateVertexArrays(1, &vao)
            if vao == 0 {
            fatalError()
        }

        // glEnableVertexAttribArray and glVertexAttribPointer must match a shaders 
        // ``layout (location = 0) in vec2 someVariable`` declaration, where ``location=0`` matches 
        // ``glEnableVertexAttribArray(0)`` and the attribPointer tells openGL how to find our data in a void*-pointer.
        // we could enable more "pointers" if we would add things like color or texture uv-coordinates to a Vertex
        GL.glBindVertexArray(vao);
        GL.glBindBuffer(GL_ARRAY_BUFFER, vbo)
        GL.glBufferData(GL_ARRAY_BUFFER, Int32(vertices.count * MemoryLayout<Float>.size), &vertices, GL_STATIC_DRAW)
        GL.glEnableVertexAttribArray(0)
        GL.glVertexAttribPointer(0, 3, GL_FLOAT, GLboolean(GL_FALSE), Int32(3 * MemoryLayout<Float>.size), nil)
        GL.glBindBuffer(GL_ARRAY_BUFFER, 0)
        GL.glBindVertexArray(0);
    }

    // TODO: Each drawable shape should have a component [ Transform ]
    func rotate(angle: Float) {
        modelMatrix = SGLMath.rotate(modelMatrix, angle, Vector3(0, 0, 1))
    }

    func draw(shader: Shader) {
        do {
            print("Drawing triangle")
            // wip, just to test: Set a color
            let time = Date().timeIntervalSince1970
            let green = (sin(time) / 2.0) + 0.5;
            let red = (cos(time) / 2.0) + 0.5;
            let uniform = try shader.uniform(name: "inColor")
            GL.glUniform4f(uniform, GLfloat(red), GLfloat(green), 0.0, 1.0)

            // set model matrix
            let modelUniform = try shader.uniform(name: "M")
            // TODO: This construction sucks ...
            withUnsafeBytes(of: modelMatrix) { rawBuffer in
                let buffer = UnsafeBufferPointer(start: rawBuffer.baseAddress!.assumingMemoryBound(to: Float.self), count: 4 * 4)
                GL.glUniformMatrix4fv(modelUniform, 1,  GLboolean(GL_FALSE), buffer.baseAddress)
            }

            // draw...
            // TODO Advanced: Draw same gemoetry with different model matrices at the same time
            GL.glBindVertexArray(vao);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            GL.glDrawArrays(GL_TRIANGLES, 0, numVertices);
            GL.glBindVertexArray(0);
            }
        catch GLError.uniformNotFound(let uniform) {
            print("Shader \(shader.name): Could not find uniform named \(uniform)")
        }
        catch {
            // no other errors should be thrown here
        }
    }
}