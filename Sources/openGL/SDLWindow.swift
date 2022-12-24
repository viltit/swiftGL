import CSDL2
import CGL

/**
    Creates a system-dependent window with SDL2
    The window is always defined as an openGL-Window. It can NOT be used with the SDL2-integrated renderer
*/
public class SDLWindow {

    internal let windowPtr: OpaquePointer

    deinit {
        SDL_DestroyWindow(windowPtr) 
    }

    init(name: String, frame: Frame, options: Options = [ ]) throws {

        // we ALWAYS use an openGL-Window
        var windowOptions = Options([ .openGL ])
        windowOptions.insert(options)
        if case .fullscreen = frame {
            windowOptions.insert(.fullscreen)
        }

         self.windowPtr = try SDL_CreateWindow(
            name, 
            frame.x,
            frame.y ,
            frame.width,
            frame.height,
            windowOptions.rawValue
        ).sdlThrow(error: SDL2Error.failedToCreateWindow)

        _ = try SDL_GL_CreateContext(windowPtr).sdlThrow(error: SDL2Error.failedToCreateWindow)

        if glewInit() != GLEW_OK {
            throw SDL2Error.failedToCreateWindow
        }

        print("Renderable window size: \(self.drawableSize.width) / \(self.drawableSize.height)")

        glClearColor(1.0, 1.0, 0.0, 1.0)
        glViewport(0, 0, self.drawableSize.width, self.drawableSize.height);
        glEnable(UInt32(GL_DEPTH_TEST))
        glEnable(UInt32(GL_BLEND))
        glEnable(UInt32(GL_CULL_FACE))
        glCullFace(UInt32(GL_BACK));
    }

    /**
    clear the currently displayed window. Use before calling ``swap``
    */
    public func clear() {
	    glClearDepth(1.0);
	    glClear(Clear([ .color, .depth ]).rawValue);
    }

    /**
    Render new frame on the screen. 
    Only works with openGL
    TODO: Do nox fixate on openGL ??? with ProtocolWindow -> OpenGLWindow ??
    */
    public func swap() {
        SDL_GL_SwapWindow(windowPtr)
    }

     /// Get window size in points
    public var size: Size<Int32> {
        get {
            var width: Int32 = 0
            var height: Int32 = 0
            SDL_GetWindowSize(windowPtr, &width, &height)
            
            return Size(width: width, height: height)
        }
        
        set { SDL_SetWindowSize(windowPtr, newValue.width, newValue.height) }
    }

    /*  Size of a window's underlying drawable in pixels (for use with glViewport).
        This may differ from `size` if the window was created with `.allowRetina`
    */
    public var drawableSize: Size<Int32> {
        
        var width: Int32 = 0
        var height: Int32 = 0
        SDL_GL_GetDrawableSize(windowPtr, &width, &height)
        
        return Size(width: width, height: height)
    }

    
    /// The output size in pixels of a rendering context
    public var rendererSize: Size<Int32>? {
        
        var width: Int32 = 0
        var height: Int32 = 0
        guard SDL_GetRendererOutputSize(windowPtr, &width, &height) >= 0
            else { return nil }
        
        return Size(width: width, height: height)
    }


}

extension SDLWindow {

    struct Options: OptionSet {

        let rawValue: UInt32

        /// fullscreen with no border nor a closing x
        internal static let fullscreen = Options(rawValue: 0x00000001)
        /// fullscreen with window border from the system
        static let fullscreenDesktop = Options(rawValue: 0x00001001) // ( SDL_WINDOW_FULLSCREEN | 0x00001000 )
        /// window can be used by opengl
        internal static let openGL = Options(rawValue: 0x00000002)
        /// window is visible
        static let visible = Options(rawValue: 0x00000004)
        /// window is hidden
        static let hidden = Options(rawValue: 0x00000008)
        /// window is borderless
        static let borderless = Options(rawValue: 0x00000010)
        /// window can be resized
        static let resizable = Options(rawValue: 0x00000020)
        /// window is minimized
        static let minimized = Options(rawValue: 0x00000040)
        /// window is maximized
        static let maximized = Options(rawValue: 0x00000080)
        /// window has grabbed input focus
        static let inputGrabbed = Options(rawValue: 0x00000100)
        /// window has input focus
        static  let inputFocus = Options(rawValue: 0x00000200)
        /// window has mouse focus
        static let mouseFocus = Options(rawValue: 0x00000200)
        /// window should be created in retina / high-dpi mode if supported
        static let allowRetina = Options(rawValue: 0x00002000)

        /*
        /// window has mouse captured (unrelated to input_grabbed, >= sdl 2.0.4)
        case mouseCapture = 0x00004000
        
        /// window should always be above others (x11 only, >= sdl 2.0.5)
        case alwaysOnTop = 0x00008000
        
        /// window should not be added to the taskbar (x11 only, >= sdl 2.0.5)
        case skipTaskbar = 0x00010000
        
        /// window should be treated as a utility window (x11 only, >= sdl 2.0.5)
        case utility = 0x00020000
        
        /// window should be treated as a tooltip (x11 only, >= sdl 2.0.5)
        case tooltip = 0x00040000
        
        // window should be treated as a popup menu (x11 only, >= sdl 2.0.5)
        case popupMenu = 0x00080000
        */
    }

    struct Clear : OptionSet {

        let rawValue: UInt32

        static let color = Clear(rawValue: UInt32(GL_COLOR_BUFFER_BIT))
        static let depth = Clear(rawValue: UInt32(GL_DEPTH_BUFFER_BIT))

    }


    enum Frame {

        case fullscreen
        case centered(size: Size<Int32>)
        case point(rectangle: Rectangle<Int32>)

        // static private let SDL_WINDOWPOS_UNDEFINED: CInt = 0x1FFF0000
        static private let SDL_WINDOWPOS_CENTERED: CInt = 0x2FFF0000 

        var x: CInt {
            get {
                switch self {
                    case .point(let rectangle): return CInt(rectangle.topX)
                    case .centered: return Frame.SDL_WINDOWPOS_CENTERED
                    case .fullscreen: return Frame.SDL_WINDOWPOS_CENTERED
                }
            }
        }
        var y: CInt {
            get {
                switch self {
                    case .point(let rectangle): return CInt(rectangle.topY)
                    case .centered: return Frame.SDL_WINDOWPOS_CENTERED
                    case .fullscreen: return Frame.SDL_WINDOWPOS_CENTERED
                }
            }
        }
        var width: CInt {
            get {
                switch self {
                    case .point(let rectangle): return CInt(rectangle.width)
                    case .centered(let size): return size.width
                    case .fullscreen: return 0  // TODO: Make sure this works with fullscreen flag
                }
            }
        }
        var height: CInt {
            get {
                switch self {
                    case .point(let rectangle): return CInt(rectangle.height)
                    case .centered(let size): return size.height
                    case .fullscreen: return 0  // TODO: Make sure this works with fullscreen flag
                }
            }
        }
    }
}