import SGLMath


class Transform2D {

    private var _pos: vec3
    private var _scale: vec3
    
    // TODO: Rotation matrix? Not really needed in 2D
    // TODO: Degrees or radians?
    private var _angle: Float
    
    var position: vec3 {
        get {
            return _pos
        }
        set(value) {
            _pos = value
        }
    }

    var scale: vec3 {
        get {
            return _scale 
        }
        set(value) {
            scale = value 
        }
    }

    var angle: Float {
        get {
            return _angle
        }
        set(value) {
            // reduce the angle  
            _angle = value % 360; 
            // force it to be the positive remainder, so that 0 <= angle < 360  
            _angle = (_angle + 360) % 360;  
            // force into the minimum absolute value residue class, so that -180 < angle <= 180  
            if (_angle > 180)  {
                _angle -= 360;  
            }
        }
    }

    var rotate: Float {
    @available(*, unavailable)
    get {
        return 0
    }
        set(value) {
            angle = _angle + value
        }
    }

    var matrix: mat4 {
        var result = SGLMath.scale(mat4(), _scale)
        result = SGLMath.rotate(result, _angle, vec3(0, 0, 1))
        return SGLMath.translate(result, _pos)
    }

    init(position: vec3, scale: vec3 = vec3(1, 1, 1)) {
        _pos = position 
        _scale = scale 
        _angle = 0
    }
}