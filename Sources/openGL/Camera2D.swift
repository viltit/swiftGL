import SGLMath

/**
    Very basic 2-d camera 
    TODO: More getters and setters (zoomMin, sensitivity, ...)
    TODO: Smooth movement by storing a deltaPos and in every update decrease deltaPos
*/
class Camera2D {

    private var pos: vec3
    private var rotation: Float = 0
    private var zoom: Float = 1
    private var zoomMin: Float = 0.1
    private var sensitivity: Float = 0.5

    /// orthografix matrix, changes when window aspect changes
    var O: mat4
    /// view matrix, changes when cameras zoom or position changes
    var V: mat4   

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
        O = SGLMath.ortho(
            -Float(windowSize.width) / 2.0, Float(windowSize.width) / 2.0, 
            -Float(windowSize.height) / 2.0, Float(windowSize.height) / 2.0, 
            Float(-100), Float(100))   // TODO: Good values for near and far plane ??
        V = mat4()
    }

    // TODO: Resetting V matrix to 0 may be a waist of resources
    // TODO: Take care of the translate - rotate - scale - order 
    func update() {

        // TODO: We could smoothe the camera movement by storing the position change in the last update and using a 
        // fraction of it again

        V = mat4()
        V = SGLMath.translate(V, pos)
        V = SGLMath.scale(V, vec3(zoom, zoom, zoom))
        // TODO: Rotate camera ??
    }

    func move(along vector: vec3) {
        pos += vector
    }

    // TODO: Also add a zoomMax
    func zoom(delta: Float) {
        zoom = (zoom + delta < zoomMin) ? zoomMin : zoom + delta
        print("Delta: \(delta)")
        print("Zoom: \(zoom)")
    }

    /// call when window is resized. Missing to call this function will result in distorted geometries
    /// TODO: This lead to a bigger/smaller visible scene on screen change
    /// TODO: Just use the window aspect to keep geometries, but otherwise used fixed widht and height
    func resize(windowSize: Size<Int>) {
        O = SGLMath.ortho(
            -Float(windowSize.width) / 2.0, Float(windowSize.width) / 2.0, 
            -Float(windowSize.height) / 2.0, Float(windowSize.height) / 2.0, 
            Float(-100), Float(100))   // TODO: Good values for near and far plane ??
    }
}