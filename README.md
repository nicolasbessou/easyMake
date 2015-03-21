# EasyMake

EasyMake simplifies the way you write makefiles.
It provides a boilerplate file to helps you write the minimum amount of code. You simply need to define some variables and include the *build.mk* file at the end of your makefile.

**Features:**
- Automatically find dependencies
- Provides default "all", build", "clean" and "run" targets
- Easily build executables, dynamic and static libraries
- Easily set target dependencies
- Provides default compilation flags
- Organise all object and binary files into a specific folder
- Add default compilation flags for debug and release configuration

### Examples

Assuming that you want to build an executable from 2 source files "bar.c" and "foobar.c", you can write the below file named "Makefile" to generate it.

```Makefile
TARGET   = foo
SRCS     = bar.c foobar.c
INC_DIRS = include
BUILD    = exe
include build.mk
```

Then, the following commands can be ran:
- `make` to build the executable
- `make clean` to remove the executable file and all object files
- `make run` to run the executable
- `make run CONFIG=debug ARCH=x86` to build the executable in debug configuration and for x86 architecture and run it.
- `make run CMD_ARGS=-p -s` to run the executable with command line arguments

### Tests

Some additional examples can be found in the folder test:
- testHelloWorld shows a basic example.
- testStaticLib shows how to include a dependent static libarry to your executable.

### Configuration

Here is the list of the variables that can be set before include "build.mk"

**BUILD** defines what kind of binary file to build
- "exe" to build an executable file
- "lib" to build a static library
- "dll" to build a dynamic library

**TARGET** sets the name of the target
- if static  library (BUILD = lib): binary name will be lib$(TARGET).a
- if dynamic library (BUILD = dll): binary name will be lib$(TARGET).so
- if executable      (BUILD = exe): binary name will be $(TARGET)

**SRCS** defines the source file that will be compiled
- C   files with the following extensions are supported: .c
- CPP files with the following extensions are supported: .C .cc .cp .cpp .CPP .cxx .c++

**SRC_DIR** defines the source file directory.
- By default it is the current working directory.
- SRCS are defined relatively to this path.

**INC_DIRS** defines the include header directories
- Do not use "-I"

**LIBS** links external libraries with the current target.

**SUB_LIBS** defines the dependent sub makefiles that needs to be linked with current target.
- The target of the sub makefiles must be a static library (BUILD=lib)
- The target name must be the same than makefile name (ex: file = foo.mk <-> target = foo )
- See testStaticLib for a usage example.

**SUB_MAKEFILES** defines the sub makefiles required to build the current target.
- The default target of the sub makefile will be called.
- The sub mkefiles won't be automatically linked with the current target as they can be any makefiles.

**CONFIG** defines the build configuration
- "release" builds with NDEBUG preprocessor macro enabled and optimization flags
- "debug" builds with DEBUG preprocessor macro enabled and no optimization flags

**ARCH** defines the architecture for which the target will be built
- "x64" for 64 bits CPUs
- "x86" for 32 bits CPUs

**CMD_ARGS** defines the command line arguments to use when running `make run`.

**ADD_DEFAULT_FLAGS** adds default compilation flags adapted for debug and release mode.

**EXTRACFLAGS** defines additional compilation flags to use for compilation

**CPPFLAGS** defines the preprocessor flags (use it without -D)

**COFLAGS** Sets some optimization flags

**LDOFLAGS** Sets flags used at link time.

**BIN_DIR** defines the directory where binary files will be written

**OBJ_DIR** defines the directory where object and dependency files will be written
