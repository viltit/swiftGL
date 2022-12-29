
// TODO much later: Base class/ protocol [GLDrawable] ? 
import CGL
import Foundation
import SGLMath

class Triangle : DrawableGLCommon { 

    init(position: vec3 = vec3()) {

        // TODO: Use a struct [Vertex] that also has colors
        // TODO advanced: Make a struct/protocol [Vertex] that can or can not have additional fields 
        var vertices: [ Vertex ] = [
            Vertex(position: vec3(-100, -100, 0.0)),
            Vertex(position: vec3(100, -100, 0.0)),
            Vertex(position: vec3(0.0,  100, 0.0))
        ]
        super.init(vertices: &vertices)
        transform.position = position
    }

    override func draw(shader: Shader) {
        do {
            // wip, just to test: Set a color
            let time = Date().timeIntervalSince1970
            let green = (sin(time) / 2.0) + 0.5;
            let red = (cos(time) / 2.0) + 0.5;
            let uniform = try shader.uniform(name: "inColor")
            GL.glUniform4f(uniform, GLfloat(red), GLfloat(green), 0.0, 1.0)

            // set model matrix
            let modelUniform = try shader.uniform(name: "M")
            // TODO: This construction sucks ...
            withUnsafeBytes(of: transform.matrix) { rawBuffer in
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