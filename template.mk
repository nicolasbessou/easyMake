
TARGET = gtest
SRCS = gtest-all.cc
INC_DIRS = ext/gtest-1.7.0 ext/gtest-1.7.0/include
SRC_DIR = ext/gtest-1.7.0/src

# Target type (exe, lib or dll)
BUILD = lib

EXTRACFLAGS = -pthread
ADD_DEFAULT_FLAGS = true

include build.mk

