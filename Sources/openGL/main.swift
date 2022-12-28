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
uniform mat4 M;

void main()
{
    fragColor = vec4(inColor.r, inColor.g, 0.0, 1.0);
    gl_Position = M * vec4(v_pos, 1.0);
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

do {
    let shader = try Shader(
        name: "Simple shader", 
        sourceVertexCode: vertexShaderSource, 
        sourceFragmentCode: fragmentShaderSource)

    let triangle = Triangle()

    gameLoop(shader: shader, triangle: triangle)

    print("SDL2 quits now")
    SDL2.quit()
}
catch GLError.shaderLinkingError(let log, let shaderName) {
    print("Shader named '\(shaderName)' error. Logfile: \n \(log)")

}
catch GLError.shaderCompileError(let log, let shaderName) {
    print("Shader named '\(shaderName)' error. Logfile: \n \(log)")
}

private func gameLoop(
    shader: Shader /*TODO: Much later, shaders should be bound to drawable game objects in a class [Scene] */,
    triangle: Triangle) {

    var event = SDL_Event()
    var isRunning = true

    while isRunning {
        
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
            // Keyboard events, TODO: Handle in its own class
            case SDL_KEYDOWN:
                switch(event.key.keysym.sym) {
                    case Int32(SDLK_ESCAPE):    // TODO: And another ugly cast
                        isRunning = false
                    case Int32(SDLK_a):
                        triangle.rotate(angle: 0.1)
                    case Int32(SDLK_d):
                        triangle.rotate(angle: -0.1)
                default:
                    break
                }
            default:
                break
        }

        do {
            shader.on()
            triangle.draw(shader: shader)
            shader.off()
        }

        // TODO: Window needs a method to fetch displays native refresh rate (SDL_GetWindowDisplayMode)
        // TODO: Add timer and wait for next loop according to screens refresh rate
        window.swap()
    }
}
