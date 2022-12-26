# swiftGL

*Testing if and with how much of a hasse we can get Swift working with SDL2 and OpenGL*

## To dos

### Immediate
- take care of compile problems on MacOS
- take care of multiple warnings: ``initialization of 'UnsafeMutablePointer<CChar>' (aka 'UnsafeMutablePointer<Int8>') results in a dangling pointer`` 
- We will need a math library analogous to [OpenGL Mathematics](https://glm.g-truc.net/0.9.9/). **Be aware this library also provides convienient functions to push matrices to openGL in the correct memory alignment** (ie ``glm::value_ptr(someMatrix)``)
- Math library will be needed to add support for Model, Perspective and View matrices and will also be needed for a (2D)Camera
- Can we make a scripts that defines all openGL-Functions in ``glWrapper.swift`` ?


### Advanced
- Goal: Make a class ``Scene`` that holds all drawable objects and has the methods ``scene.draw()`` and ``scene.update()``.
- On a higher level, it should be possible to create and draw a scene without a single direct call to any C-Library