import SGLMath

/**
    Very basic 2-d camera 
*/
class Camera2D {

    private var pos: vec3
    private var rotation: Float = 0
    private var zoom: Float = 100
    private var sensitivity: Float = 0.5

    /// orthografix matrix, changes when window aspect changes
    private var O: mat4
    /// view matrix, changes when cameras zoom or position changes
    private var V: mat4   

    /// getters and setters
    var matrix: mat4 {
        get {
            return O*V
        }
    }

    var position: vec3 {
        get {
            return pos
        }
        set(value) {
            pos = value
        }
    }

    // TODO: Set zoom, rotate camera, set near and far plane, make use of sensitivity, etc.
    init(windowSize: Size<Int32>, position: vec3) {

        self.pos = position
        O = SGLMath.ortho(Float(0), Float(windowSize.width), Float(windowSize.height), Float(0))
        V = mat4()
    }

    // TODO: Resetting V matrix to 0 may be a waist of resources
    // TODO: Take care of the translate - rotate - scale - order 
    func update() {

        // TODO: We could smoothe the camera movement by storing the position change in the last update and using a 
        // fraction of it again

        V = mat4()
    //    V = SGLMath.translate(V, pos)
    //    V = SGLMath.scale(V, vec3(zoom, zoom, zoom))
        // TODO: Rotate camera ??
    }

    func move(along vector: vec3) {
        pos += vector
    }

    /// call when window is resized. Missing to call this function will result in distorted geometries
    func resize(windowSize: Size<Int>) {
        O = SGLMath.ortho(Float(0), Float(windowSize.width), Float(windowSize.height), Float(0), Float(0.001), Float(100))
    }
}