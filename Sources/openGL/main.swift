/**
see https://forums.swift.org/t/how-do-i-nicely-wrap-a-c-library-sdl/30943/3 for some hint
https://swiftgl.github.io/
*/

// TODO: Imports from C should not be needed at this level -> wrap SDL_Event? Very tedious
import CSDL2
import CGL
import SGLMath
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
uniform mat4 C; 
uniform mat4 M;

void main()
{
    fragColor = vec4(inColor.r, inColor.g, 0.0, 1.0);
    gl_Position = C * M * vec4(v_pos, 1.0);
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

    // TODO: window.size or window.drawableSize 
    let camera = Camera2D(windowSize: window.size, position: vec3(0, 0, -1))

    gameLoop(shader: shader, triangle: triangle, camera: camera)

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
    triangle: Triangle,
    camera: Camera2D) {

    var event = SDL_Event()
    var isRunning = true

    while isRunning {
        
        window.clear()
        
        // TODO: How can we avoid accessing CSDL directly ?
        while SDL_PollEvent(&event) == 1 {
            switch SDL_EventType(rawValue: event.type) {
                case SDL_QUIT, SDL_APP_TERMINATING:
                    isRunning = false
                case SDL_WINDOWEVENT:
                    if event.window.event == UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue) {
                        window.size = Size(width: event.window.data1, height: event.window.data2)
                        camera.resize(windowSize: Size(width: Int(event.window.data1), height: Int(event.window.data2)))
                    } 
                // Keyboard events, TODO: Handle in its own class
                case SDL_KEYDOWN:
                    switch(event.key.keysym.sym) {
                        case Int32(SDLK_ESCAPE):    // TODO: And another ugly cast
                            isRunning = false
                        case Int32(SDLK_a):
                            camera.move(along: vec3(5, 0, 0))
                        case Int32(SDLK_d):
                            camera.move(along: vec3(-5, 0, 0))
                        case Int32(SDLK_w):
                            camera.move(along: vec3(0, -5, 0))
                        case Int32(SDLK_s):
                            camera.move(along: vec3(0, 5, 0))
                    default:
                        break
                    }
                case SDL_MOUSEWHEEL:
                    if event.wheel.y > 0 {
                        camera.zoom(delta: 0.1)
                    }
                    else if event.wheel.y < 0 {
                        camera.zoom(delta: -0.1)
                    }
                default:
                    break
            }
        }

        do {
            shader.on()
            camera.update()

            // TODO: Camera view matrix works, but cameras ortho matrix seems bugged

            let cameraUniform = try shader.uniform(name: "C")
            let m = camera.matrix
             withUnsafeBytes(of: m) { rawBuffer in
                let buffer = UnsafeBufferPointer(start: rawBuffer.baseAddress!.assumingMemoryBound(to: Float.self), count: 4 * 4)
                GL.glUniformMatrix4fv(cameraUniform, 1,  GLboolean(GL_FALSE), buffer.baseAddress)
            }
            // print(camera.matrix)
            triangle.draw(shader: shader)
            shader.off()
        }
        catch {
            print(error)
        }

        // TODO: Window needs a method to fetch displays native refresh rate (SDL_GetWindowDisplayMode)
        // TODO: Add timer and wait for next loop according to screens refresh rate
        window.swap()
    }
}
