GP 2: Graph Programming
=======================

Authors: Chris Bak and Glyn Faulkner (May 14th 2015)

GP 2 is a graph programming language. Graph programs consist of two text files. The first is a specification of the graph program, namely a set of graph transformation rules and a procedural-style command sequence to organise rule application. The second describes an initial _host graph_ to which the graph program is applied. These text files can be written in a text editor. A graphical editor is under development to construct programs visually. Graph programs are executed by either passing them to an interpreter, or by compiling to native code.


Compiler
========

The Compiler directory contains a C compiler that translates GP 2 textual programs to executable C code. Instructions for building and running the compiler are contained in the directory.


Haskell
=======

The Haskell directory contains a reference interpreter for GP 2 implemented in Haskell, a compiler that generates OILR Machine instructions (see below), and several ancillary tools for viewing and testing GP 2 host graphs.

Typing `make` in the Haskell directory produces the following binaries:

`gp2`: The GP2 reference interpreter.

`gp2c`: The OILR machine compiler, which generates a C file that can be compiled and linked against the OILR Machine runtime.

`ViewGraph`: A host graph visualiser (using GraphViz as a back-end).

`IsoChecker`: A standalone host graph comparison tool, which checks whether two host graphs are isomorphic.



OilrMachine
===========

The OILR machine is a specialised graph language abstract machine.


Build instructions (basic graph data structure)
-----------------------------------------------

Typing `make` in the OilrMachine directory builds the OILR runtime, `oilrrt.a` using a simplistic graph representation.


Build instructions (full graph data structure)
-----------------------------------------------

To build the OILR runtime using the full graph data structure:

> make -f Makefile.gp2


Compiling GP 2 programs
----------------------

Compile a GP 2 program to C:

> gp2c prog.gp2 graph.host


To compile a GP 2 program generated by `gp2c`, you will need the runtime static library, and the two header files `oilrrt.h` and `oilrinst.h`. 

> gcc -o prog prog.c oilrrt.a

