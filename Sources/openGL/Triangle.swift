
import CGL
import Foundation
import SGLMath

/// TODO: generating Drawables may be a good use case for a Factory / Builder Pattern
class Triangle : DrawableGLCommon {

    init(position: vec3 = vec3(), color: vec4 = vec4(1, 1, 1, 1)) {
        var vertices: [ Vertex ] = [
            Vertex(position: vec3(-100, -100, 0.0), color: color),
            Vertex(position: vec3(100, -100, 0.0), color: color),
            Vertex(position: vec3(0.0,  100, 0.0), color: color)
        ]
        super.init(vertices: &vertices)
        transform.position = position
    }
}

class Rectangle2D : DrawableGLCommon { 

    init(position: vec3 = vec3(), color: vec4 = vec4(1, 1, 1, 1)) {
        var vertices: [ Vertex ] = [
            Vertex(position: vec3(-100, -100, 0.0), color: color),
            Vertex(position: vec3(100, -100, 0.0), color: color),
            Vertex(position: vec3(-100,  100, 0.0), color: color),
            Vertex(position: vec3(-100,  100, 0.0), color: color),
            Vertex(position: vec3(100, -100, 0.0), color: color),
            Vertex(position: vec3(100, 100, 0.0), color: color),
        ]
        super.init(vertices: &vertices)
        transform.position = position
    }
}
