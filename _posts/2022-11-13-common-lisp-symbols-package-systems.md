---
layout: post
title: Common lisp: Symbols, Packages, Systems
---

# Common lisp: Symbols, Packages, Systems

The Common Lisp
[REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
can be thought of as the program running the one-liner

    (loop (print (eval (read))))

The `read` function implements the functionality of the [Lisp
reader](https://en.wikipedia.org/wiki/Lisp_reader), who is responsible
for taking in a stream of characters and producing objects.

An object, (in case you don't know what that is,) can be thought of as
a structured region of memory.

An imaginary `String` object may look as follows

![a string object](/docs/assets/images/object.png)

A reader, more generally than just in lisp, may read a line from a
stream such as

    String { 3, "cat" }

and _create_ from it the object depicted in the figure.

Now let's get to Common Lisp specifics.

## The Lisp image

The Lisp image is a process that runs lisp on your computer. Just like
virtual machine images, or docker images, it can be saved and
restarted (hence the name). Back in the day, Lisp brought these
features to the forefront thanks to its clean (and clever) design that
stayed out of the way of feature building.

Although I have not used these particular features of lisp images, it
is useful to think of the lisp image as an ever-running process that
can introspect and update itself. All Common Lisp source code is fed
serially into the REPL, and the image updates itself with new
definitions, and so on. When we type `"cat"` at the REPL, an object
similar to the above is created in the lisp image:

![the lisp image](/docs/assets/images/lisp-image.png)

Everything, or almost everything, is an object in Common Lisp.

After the object has been used in whatever functions are called that
involve it, it will linger for a bit, and then be collected by the
[Garbage
Collector](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)),
which means that it gets automatically deallocated. How does the
Garbage Collector know that the object is not needed anymore? It uses
a technique known as [reference
counting](https://en.wikipedia.org/wiki/Reference_counting). If no
other object references it, then it is not accessible. Think about our
`"cat"` object. How can we access it again? We could type `"cat"` once
more of course, but it may be a new object! (in fact this situation is
permitted in Common Lisp, as the hyperspec on the `eq` function
shows.) It would be rudimentary to type

    (defconstant +pet+ "cat")

and thus access the same object as many times as we'd like by typing
`+cat+` to the REPL. (the `+` surrounds are a Common Lisp naming
convention for constants.) Remember how everything was an object? Now
the situation in the lisp reader looks like this:

![the lisp image](/docs/assets/images/lisp-image2.png)

Since (almost) everything in Common Lisp is an object, the name (or
variable) of the string is an object too. But... what kind of object
is a variable name? It turns out, it is a "symbol".

## Symbols

The word [symbol](https://en.wiktionary.org/wiki/symbol) is
interesting, but whatever you're familiar with from the English
language or other programming languages may confuse you when it comes
to Common Lisp symbols.

Those so-called symbols are simply references to objects in the Lisp
image. Fundamentally, they consist of two parts, a name and a value.

![a symbol](/docs/assets/images/symbol.png)

(We say "fundamentally" because Common Lisp symbols have more parts;
and by the way, instead of "parts" they are called "slots".)

Let us point out how the problem of accessing the cat string has been
solved. When we type `+pet+` to the REPL, the reader will read `+pet+`
as a stream of characters, and will recognize it for a symbol. Then
something delicate happens: if the symbol name `"+PET+"` already has
been assigned to a symbol, that symbol will be returned by the Lisp
reader. If no such symbol exists, a brand new symbol will be created
in the Lisp image, with its value slot empty, and will be returned by
the reader. In the Lisp evaluator, symbols evaluate to their values,
which in the case of `+pet+` is the cat string.

Now our string won't be garbage collected: it is referenced by another
object, a symbol. But who keeps the symbol itself from getting garbage
collected? The answer is "packages".

## Packages

Packages in programming are understood as reusable abstractions, and
indeed that's what they're used for in Common Lisp too. Nevertheless,
packages in Common Lisp are very lightweight: a package keeps track of
a set of symbols.

Packages are objects themselves, but they are not tracked by other
objects, but rather by the implementation. The `list-all-packages`
function lists the created packages. (thus, whatever keeps track of
the packages is an object itself; it is part of the implementation,
not the [Common Lisp object
system](https://en.wikipedia.org/wiki/Common_Lisp_Object_System).)

Pakcages are created with `make-package` or the
[higher-level](https://en.wikipedia.org/wiki/High-_and_low-level)
`defpackage`.

Tracked symbols may be internal, inherited, or external. The external
symbols of the package form its public interface. The inherited
symbols are imported from other packages, as dependencies. The
internal symbols are pseudo-private; they can be accessed but probably
shouldn't.

To access the value of a symbol in a package, use

    (find-symbol symbol-name package-designator)

The reader has some conventions to make it less verbose to access
symbols. Remember the aforementioned delicate process? It looks up
symbols in `*package*`, the current package, which by default in a
fresh Lisp image is `common-lisp-user`. However, if the symbol is of
the form `<package>::<name>`, the name `<name>` is instead looked up
in the given package `<package>`, instead of the current package, and
if not found, it is created. On the other hand, if it is of the form
`<package>:<name>` (note the one colon instead) it is merely looked up
in the package's external symbol list, and if not found, it is not
created.

The Lisp printer plays a part too: when symbols are printed, the
prefix package is either trimmed or added, depending on whether it is
the same or different to the current package.

There remains to explain what `'symbol` and `:keyword` are, which you
have undoubtedly encountered in Common Lisp source code. The quote
character makes the evaluator return the symbol object itself instead
of its value, with all previous rules about symbol lookup and creation
from the reader applying. The colon causes the symbol to be created in
the special package `KEYWORD`. Symbols in this package are
self-referential!

![a symbol](/docs/assets/images/symbol2.png)

Thus their evaluation by the evaluator returns back their own
self. This trick allows us to pass keywords as arguments to functions.

So far we have described how to create a single package or a single
symbol. A typical use of packages is as follows

    (defpackage #:my-package
      (:use :cl)
      (:export #:my-function))
    (in-package #:my-package)
    
    (defun my-function ()
      "Compute the answer to everything."
      42)

Anyone who would like to use the above could `load` the file and start
using `my-function`, but nowadays it is common to use
[ASDF](https://asdf.common-lisp.dev/) for the purpose of loading
packages.

## ASDF and systems

Systems load packages, but they can do more. They can manage internal
and external dependencies, (with
[Quicklisp](https://www.quicklisp.org/) automatically fetching and
installing external dependencies,) as well as run the test suite,
build executables, other custom commands and so on.

Although the use of Quicklisp can be debated, ASDF is undebatably the
way to go when distributing Common Lisp source code. Moreover,
Quicklisp does not require any tinkering from the programmer; the user
only has to install and configure it and then it knows what to
do. Thus Quicklisp comes at zero-cost for the programmer.

ASDF has `.asd` files in its configured paths that tell it how to load
systems specified in `asdf:load-system`. Each `.asd` file has a
primary system and subsidiary systems, and their dependencies form
[directed acyclic
graphs](https://en.wikipedia.org/wiki/Directed_acyclic_graph).

## Gotchas

It's worthwhile to explain `#:my-function`, which we used when
defining a package. When the reader encounters this syntax, it
launches a _reader macro_ which transforms it to `(make-symbol
"MY-FUNCTION")`. It would be erroneous to use `'my-function` in the
export section of `defpackage`, since the reader would create a new
symbol `my-function` in the current package (this might be harmless,
but it's common practice in Common Lisp to use `#:symbols` for package
definitions.) By the same logic we use `#:my-package`. Strings of
course may be used too for package and symbol name designators, but
they are less convenient to type out.  (Because they need to be
uppercase, that's another quirk of the Lisp reader.)

Packages can't track two symbols with the same name. That is a name
clash. Name clashes can happen when importing symbols, and they can be
resolved by shadowing symbols, which trump over others in name
clashes.
