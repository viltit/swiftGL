public struct Rectangle<T: Numeric> {

    init() {
        topX = 0
        topY = 0
        width = 0
        height = 0
    }

    public let topX: T 
    public let topY: T 
    public let width: T 
    public let height: T 
}

public struct Point2D<T: Numeric> {
    public let x: T
    public let y: T
}

public struct Size<T: Numeric> {
    public let width: T
    public let height: T
}