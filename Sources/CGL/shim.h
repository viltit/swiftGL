#ifdef __APPLE__
#include "/opt/homebrew/include/GL/glew.h"
// TODO: We also need apples version of glx.h
#else
#include <GL/glew.h>
#include <GL/glx.h>
#endif