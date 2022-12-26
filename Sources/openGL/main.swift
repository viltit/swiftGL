/**
see https://forums.swift.org/t/how-do-i-nicely-wrap-a-c-library-sdl/30943/3 for some hint
https://swiftgl.github.io/
*/

// TODO: Imports from C should not be needed at this level -> wrap SDL_Event? Very tedious
import CSDL2
import CGL
import Foundation

try SDL2.start(subsystems: [ .video, .audio ] )
if (SDL2.isInitialized(subsystems: .video)) {
    print("SDL2 video was initialized")
}
else {
    print("SDL2 video was not initialized")
}
let window = try SDLWindow(
    name: "Hello GL", 
    frame: SDLWindow.Frame.centered(size: Size(width: 300, height: 300)), 
    options: [ .resizable ])


let vertexShaderSource = """
#version 400 core

layout (location = 0) in vec3 v_pos;

out vec4 fragColor;
uniform vec4 inColor;

const vec2 quad_vertices[4] = vec2[4]( vec2( -1.0, -1.0), vec2( 1.0, -1.0), vec2( -1.0, 1.0), vec2( 1.0, 1.0));
void main()
{
    fragColor = vec4(inColor.r, inColor.g, 0.0, 1.0);
    gl_Position = vec4(v_pos, 1.0);
}
"""

let fragmentShaderSource = """
#version 400 core

in      vec4    fragColor;
out		vec4	color;

void main() {
	color = fragColor;
}
"""

// TODO: First milestone: Use Triangle when drawing and generate some pattern
do {
    let shader = try Shader(sourceVertexCode: vertexShaderSource, sourceFragmentCode: fragmentShaderSource)

    // TODO: wip
    let triangle = Triangle()

    gameLoop(shader: shader, triangle: triangle)

    print("SDL2 quits now")
    SDL2.quit()
}
catch GLError.shaderLinkingError(let log) {
    print(log)

}
catch GLError.shaderCompileError(let log) {
    print(log)
}

private func gameLoop(
    shader: Shader /*TODO: Much later, shaders should be bound to drawable game objects in a class [Scene] */,
    triangle: Triangle) {

    var event = SDL_Event()
    var isRunning = true

    while isRunning {
        
        // TODO: First swap or first clear ??
        window.clear()
        
        // TODO: How can we avoid accessing CSDL directly ?
        SDL_PollEvent(&event)
        switch SDL_EventType(rawValue: event.type) {
            case SDL_QUIT, SDL_APP_TERMINATING:
                isRunning = false
            case SDL_WINDOWEVENT:
                if event.window.event == UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue) {
                    window.size = Size(width: event.window.data1, height: event.window.data2)
                }
            // TODO: Keyboard event    
            default:
                break
        }

        do {
            // TODO: Completly wip, just show we can do *something*
            shader.on()
            let time = Date().timeIntervalSince1970
            let green = (sin(time) / 2.0) + 0.5;
            let red = (cos(time) / 2.0) + 0.5;
            let uniform = try shader.uniform(name: "inColor")
            GL.glUniform4f(uniform, GLfloat(red), GLfloat(green), 0.0, 1.0)
            triangle.draw(shader: shader)
            shader.off()
        }
        catch GLError.uniformNotFound(let uniform) {
            print("Could not find uniform named \(uniform)")
        }
        catch {
            print(error)
        }
        // TODO: Window needs a method to fetch displays native refresh rate (SDL_GetWindowDisplayMode)
        // TODO: Add timer and wait for next loop according to screens refresh rate
        window.swap()
    }
}
