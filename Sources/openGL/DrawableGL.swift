import CGL
import Foundation
import SGLMath

// TODO advanced: Make a struct/protocol [Vertex] th
// TODO: Or an enum vertex that can hold different kinds 
struct Vertex {
    let position: vec3
    let color: vec4
}

protocol DrawableGL {

    var vbo: GLuint { get set }
    var vao: GLuint { get set }
    var numVertices: GLsizei { get }

    var transform: Transform2D { get }

    func draw(shader: Shader)
}

/// TODO: How to provide common implementations? 
/// TODO: Maybe this would be a good case for a Factory
class DrawableGLCommon : DrawableGL {

    internal var vbo: GLuint = 0
    internal var vao: GLuint = 0
    internal let numVertices: GLsizei

    internal let transform: Transform2D = Transform2D(position: vec3(0,0,0)) 
    
    init(vertices: inout [ Vertex ]) {
        
        numVertices = GLsizei(vertices.count)
        GL.glGenBuffers(1, &vbo)
        if vbo == 0 {
            fatalError()
        }
        GL.glCreateVertexArrays(1, &vao)
            if vao == 0 {
            fatalError()
        }

        GL.glBindVertexArray(vao);
        GL.glBindBuffer(GL_ARRAY_BUFFER, vbo)
        GL.glBufferData(GL_ARRAY_BUFFER, Int32(vertices.count * MemoryLayout<Vertex>.size), &vertices, GL_STATIC_DRAW)
        GL.glEnableVertexAttribArray(0)
        GL.glVertexAttribPointer(0, 3, GL_FLOAT, GLboolean(GL_FALSE), Int32(MemoryLayout<Vertex>.size), nil)
        GL.glEnableVertexAttribArray(1)
        // TODO:  We need a clean method to get a byte offset of a field in a struct
        // TODO: This does not work: let colorOffset = MemoryLayout<Vertex>.offset(of: \.color)!
        let colorOffset =  UnsafeRawPointer(bitPattern: 12)
        GL.glVertexAttribPointer(1, 4, GL_FLOAT, GLboolean(GL_FALSE), Int32(MemoryLayout<Vertex>.size), colorOffset)
        GL.glBindBuffer(GL_ARRAY_BUFFER, 0)
        GL.glBindVertexArray(0)
    }

    func draw(shader: Shader) {

    }
} 