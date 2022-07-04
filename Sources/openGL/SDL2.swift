import CSDL2

public enum SDL2Error : Error {
    case failedToInitialize
    case failedToCreateWindow
}

public struct SDL2 {
    @inline(__always)
    static func start(subsystems: SubSystem) throws {
        try SDL_Init(subsystems.rawValue).sdlThrow(error: .failedToInitialize)
    }
    @inline(__always)
    static func quit() {
        SDL_Quit()
    }
    @inline(__always)
    static func isInitialized(subsystems: SubSystem) -> Bool {
        return SDL_WasInit(subsystems.rawValue) == subsystems.rawValue 
    }
}


extension SDL2 {    
    /// SDL Subsystems
    struct SubSystem: OptionSet {

        let rawValue: UInt32

        static let timer = SubSystem(rawValue: 0x00000001)
        static let audio = SubSystem(rawValue: 0x00000010)
        static let video = SubSystem(rawValue: 0x00000020)
        static let joystick = SubSystem(rawValue: 0x00000200)
        static let haptic = SubSystem(rawValue: 0x00001000)
        static let gameController = SubSystem(rawValue: 0x00002000)
        static let event = SubSystem(rawValue: 0x00004000)
    }
}