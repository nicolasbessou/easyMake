.PHONY: all build clean run

all: build

build:
	@$(MAKE) -C testHelloWorld
	@$(MAKE) -C testStaticLib

clean:
	@$(MAKE) -C testHelloWorld clean
	@$(MAKE) -C testStaticLib clean

run:
	@$(MAKE) -C testHelloWorld run
	@$(MAKE) -C testStaticLib run
