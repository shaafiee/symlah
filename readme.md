## To use it:

Run *svm.pl* in *src*

See section **Symlah VM Protocol (SVMP)** in [docs](docs/symlah_syntax.pdf) to find out how to run programs within *svm.pl* daemon.

## The name Symlah

The name arises from the combination of the word 'symbol' and the famous Malaysian colloquial 'lah.' The purpose of Symlah is to eliminate the need for specializing in development or analysis/design and generating a philosophy of cognitive software development through an ergonomic development interface.

## What is Symlah?

Symlah is a programming language that allows development of software using an intuitive data-flow-oriented development schema. It is a programming language because it implements many of the constructs available in other imperative programming languages which allow them to create Turing-complete applications.

Symlah is most similar to Java in the way it implements its runtime environment. Java runs all of its programs in a virtual machine within which the computations behave according to rules dissimilar to the environment within which the virtual machine is hosted (for instance, a Linux operating system). Hence, Java programs are Turing-complete within the Java virtual machine, and not necessarily within the host environment of the virtual machine. Similarly, Symlah implements a virtual machine within which its programs are executed. Hence, Turing-completeness is achieved only within this virtual machine.

The reason for creating a virtual machine for Symlah is because of the disparity of its programming paradigm. Symlah defines a paradigm which does not require (or even recognize) storage devices. Instead, all data persistence is veiled from the programmer's view. This paradigm is different from von Neumann architecture, which has served as the basis for most modern programming language designs.

Data storage automation is not a completely new paradigm in software language design. The most recent programming language enabling data storage automation is Ruby on Rails. However, even Ruby on Rails requires preparation of data storage models (called 'migrations') before the virtual machine can automate storage tasks. This means that Ruby on Rails does not break the von Neumann paradigm. Hence, there is still a need for developers using Ruby on Rails to understand a certain degree of data abstraction.

Symlah alleviates the developer from needing to understand any nuances of data storage in a computer system. This allows the developer to focus solely on the business logic definition.
