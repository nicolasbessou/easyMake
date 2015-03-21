#------------------------------------------------------------------------------#
# easyMake simplifies the way you write makefiles.
#
# Copyright (c) 2015 Nicolas BESSOU
#------------------------------------------------------------------------------#

#--------------------------------------------------------
#---- Local configuration
#--------------------------------------------------------

#### Target configuration

# Kind of binary file to build (it can be either: exe, dll or lib)
BUILD ?=

# Target name :
# if static  library (BUILD = lib): binary name will be lib$(TARGET).a
# if dynamic library (BUILD = dll): binary name will be lib$(TARGET).so
# if executable      (BUILD = exe): binary name will be $(TARGET).
TARGET ?= out

# Source files to compile
SRCS ?=

# Source files directory (SRCS path must be relative to SRC_DIR)
SRC_DIR ?= .
# Include header directories (without -I)
INC_DIRS ?= .

# External libraries to be linked with target.
LIBS ?=

# Sub makefiles of static libraries that needs to be linked with current target.
# Requirements:
# - Target name must be the same than makefile name (ex: file = foo.mk <-> target = foo )
# - Target must be a static library (BUILD=lib)
SUB_LIBS ?=

# Sub makefiles dependencies
# Call default target when building, call clean target when cleaning.
# The current target won't be linked with SUBS (use SUB_LIBS to auto-link with target)
SUB_MAKEFILES ?=


#### Compilation configuration ####
# (debug, release)
export CONFIG ?= release
# (x86, x64)
export ARCH ?= x64


#### Run configuration ####

# You can run the final target using "make run" if it's an executable.
# You can add command line arguments to pass to the executable by setting CMD_ARGS.
# For example "make run CMD_ARGS=--foo=2 -bar"
CMD_ARGS ?=


#### Compilation flags ####

# Include default flags or not. (true, false)
export ADD_DEFAULT_FLAGS ?= true
# Architecture flags (will make ARCH useless if overwritten)
export ARCH_FLAG
# Extra flags
EXTRACFLAGS ?=
# Preprocessor flags (without -D)
CPPFLAGS ?=
# Optimization flags
COFLAGS ?=
# Link flags
LDOFLAGS ?=

#### Compilation and system tools ####

# Tool to build a static library
export AR                ?= ar
# Tool to compile C and assembly files(.s)
export CC                ?= gcc
# Tool to compile C++ files
export CXX               ?= g++
# Default command to remove a directory.
export RM                ?= rm
# Default command to create a directory.
export MKDIR             ?= mkdir

#### Directory configuration ####

# Binary directory where binary files will be written
export BIN_DIR           ?= _bin/$(CONFIG)_$(ARCH)
# Object directory where object and dependency files will be written
export OBJ_DIR           ?= _obj/$(CONFIG)_$(ARCH)

#### Miscellaneous ####

# Dialect to use to compile C files
export STD_CCFLAGS       ?= -std=gnu99
# Dialect to use to compile CPP files
export STD_CXXFLAGS      ?= -std=gnu++11
# List of C supported file extensions.
export CC_SRC_EXTS       ?= .c
# List of C++ supported file extensions.
export CXX_SRC_EXTS      ?= .C .cc .cp .cpp .CPP .cxx .c++

#--------------------------------------------------------
#---- SET FLAGS
#--------------------------------------------------------

#### ARCH dependent flags ####
ifeq ($(ARCH),x86)
  ARCH_FLAG ?= -m32
else
  ARCH_FLAG ?= -m64
endif

#### Set default flags ####
ifeq ($(ADD_DEFAULT_FLAGS),true)
    ifeq ($(CONFIG),debug)
        CPPFLAGS += DEBUG
        COFLAGS  += -g -O0
        LDOFLAGS += -g
    else
        CPPFLAGS += NDEBUG
        COFLAGS  += -O3
    endif
    EXTRACFLAGS +=-Wall -Wextra -fvisibility=hidden
endif

#### Compilation flags ####
CFLAGS  := $(ARCH_FLAG)
CFLAGS  += $(COFLAGS)
CFLAGS  += $(EXTRACFLAGS)
CFLAGS  += $(CPPFLAGS:%=-D%)
CFLAGS  += $(INC_DIRS:%=-I%)

#### Link flags ####
LDFLAGS  = $(ARCH_FLAG) $(LDOFLAGS)
SOFLAGS  = $(ARCH_FLAG)

#--------------------------------------------------------
#---- OBJECTS AND DEPENDENCIES
#--------------------------------------------------------
OBJS=$(SRCS:%.c=$(OBJ_DIR)/%.o)
DEPS=$(SRCS:%.c=$(OBJ_DIR)/%.d)

define GET_OBJS_AND_DEPS_RULE
OBJS:=$$(OBJS:%$(1)=$$(OBJ_DIR)/%.o)
DEPS:=$$(DEPS:%$(1)=$$(OBJ_DIR)/%.d)
endef
$(foreach EXT,$(CXX_SRC_EXTS), $(eval $(call GET_OBJS_AND_DEPS_RULE,$(EXT))))

# Get path to binary files of SUB_LIBS, so thay can be linked with current target
SUB_LIBS_WITHOUT_PATH=$(notdir $(SUB_LIBS))
SUB_LIBS_PATH=$(SUB_LIBS_WITHOUT_PATH:%=$(BIN_DIR)/lib%.a)

# Get sub targets names
SUBS_BUILD  = $(SUB_MAKEFILES:%=%_build)
SUBS_CLEAN  = $(SUB_MAKEFILES:%=%_clean)
SUBS_BUILD += $(SUB_LIBS:%=%_build)
SUBS_CLEAN += $(SUB_LIBS:%=%_clean)

#--------------------------------------------------------
#---- BINARY TARGETS
#--------------------------------------------------------

#### Static library ####
ifeq ($(BUILD),lib)
FINAL_TARGET=$(BIN_DIR)/lib$(TARGET).a
$(FINAL_TARGET): $(OBJS)
	@echo "BUILDING LIB --> $(@F)"
	@$(MKDIR) -p $(@D)
	@$(AR) rcs $@ $^ $(SUB_LIBS_PATH)
	@echo "BUILD SUCCESSFUL !!"
endif

#### Dynamic library ####
ifeq ($(BUILD),dll)
FINAL_TARGET=$(BIN_DIR)/lib$(TARGET).so
$(FINAL_TARGET): $(OBJS) $(SUB_LIBS_PATH) $(LIBS)
	@echo "BUILDING DLL --> $(@F)"
	@$(MKDIR) -p $(@D)
	@$(CXX) $(SOFLAGS) -shared -o $@ $^ -ldl -lpthread
	@echo "BUILD SUCCESSFUL !!"
endif

#### Executable ####
ifeq ($(BUILD),exe)
FINAL_TARGET=$(BIN_DIR)/$(TARGET)
$(FINAL_TARGET): $(OBJS) $(SUB_LIBS_PATH) $(LIBS)
	@echo "BUILDING EXE --> $(@F)"
	@$(MKDIR) -p $(@D)
	@$(CXX) $(LDFLAGS) -o $@ $^ -ldl -lpthread
	@echo "BUILD SUCCESSFUL !!"
endif

#--------------------------------------------------------
#---- SUFFIXES TARGETS
#--------------------------------------------------------
#### clear out all suffixes and list only those we use ####
.SUFFIXES:
.SUFFIXES: .o .d $(CC_SRC_EXTS) $(CXX_SRC_EXTS)


#### compiling file dependencies ####
define ADD_DEPS_RULE
$$(OBJ_DIR)/%.d: $$(SRC_DIR)/%$(1)
	@echo "Generate dependencies --> $$(<F)"
	@$$(MKDIR) -p $$(dir $$@)
	@$(2) -MM $$(CFLAGS) $(3) -o $$@d $$<
	@sed 's@$$(notdir $$(@:%.d=%\.o))@$$(@:%.d=%.o) $$@@g' $$@d > $$@
	@rm -f $$@d
endef

# C dependency rules
$(foreach EXT,$(CC_SRC_EXTS), $(eval $(call ADD_DEPS_RULE,$(EXT),$(CC),$(STD_CCFLAGS))))
# CPP dependency rules
$(foreach EXT,$(CXX_SRC_EXTS), $(eval $(call ADD_DEPS_RULE,$(EXT),$(CXX),$(STD_CXXFLAGS))))


#### compiling object files ####
define ADD_OBJS_RULE
$$(OBJ_DIR)/%.o: $$(SRC_DIR)/%$(1)
	@echo "Compiling --> $$(<F)"
	@$$(MKDIR) -p $$(dir $$@)
	@$(2) -c $$(CFLAGS) $(3) -o $$@ $$<
endef

# C objects rules
$(foreach EXT,$(CC_SRC_EXTS), $(eval $(call ADD_OBJS_RULE,$(EXT), $(CC), $(STD_CCFLAGS))))
# CPP objects rules
$(foreach EXT,$(CXX_SRC_EXTS), $(eval $(call ADD_OBJS_RULE,$(EXT), $(CXX), $(STD_CXXFLAGS))))


#### include dependencies to read them all in ####
ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

#--------------------------------------------------------
#---- CALL TO SUB MAKEFILES
#--------------------------------------------------------
# Call default target of sub-makefile
$(SUBS_BUILD):
	@$(MAKE) -C $(@D) -f $(@F:%_build=%.mk)

# Call clean target of sub-makefile
$(SUBS_CLEAN):
	@$(MAKE) -C $(@D) -f $(@F:%_clean=%.mk) clean

#--------------------------------------------------------
#---- PHONY TARGETS
#--------------------------------------------------------
.PHONY: all build clean run

# Set defualt target
.DEFAULT_GOAL := all

#### default target ####
all: build

#### build sub and current project ####
build: $(SUBS_BUILD) $(FINAL_TARGET)

#### Remove all generated files ####
clean: $(SUBS_CLEAN)
	@echo "Cleaning $(TARGET) with configuration $(CONFIG)_$(ARCH)"
	@-$(RM) -f $(OBJS) $(DEPS) $(FINAL_TARGET)

#### Run built target (only for executables) ####
ifeq ($(BUILD),exe)
run: build
	./$(FINAL_TARGET) $(CMD_ARGS)
endif

