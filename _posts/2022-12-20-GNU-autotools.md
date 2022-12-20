---
layout: post
title: Notes on GNU autotools
---

# Notes on GNU autotools

These notes are a summary of the tutorial in
<https://www.lrde.epita.fr/~adl/autotools.html>.

Autotools ultimately create a `./configure` script with the
below-described features.

## Configure

`./configure` probes the system and generates `config.h` and
makefiles.

The `NAME.in` files are configuration templates from which `configure`
creates `NAME`.

In fact, `./configure` creates a `config.log` file and then a
`config.status` script that processes the templates. With `-C`, a
`config.cache` is created that speeds up reconfigurations.

### Targets

There are some standard makefile targets:

- `all`, same as `make`
- `install`
- `install-strip`, remove debugging symbols and install
- `uninstall` opposite of `install`
- `clean`, opposite of `all`
- `distclean`, additionally remove anything `./configure` generated
- `check`, run test suite
- `installcheck`, check installed programs or libraries
- `dist`, create `PACKAGE-VERSION.tar.xz`
- `distcheck`, same but with sanity checks (prefer this one)

### Filesystem hierarchy

The standard file system hierarchy is

    directory         default value
    
    prefix            /usr/local
        exec-prefix   prefix
            bindir    exec-prefix/bin
            libdir    exec-prefix/lib
            ...
        includedir    prefix/include
        datarootdir   prefix/share
            datadir  datarootdir
            mandir   datarootdir/man
            infodir  datarootdir/info

These can be set via `./configure --prefix` and so on.

### Flags

When using `./configure CFLAGS=...` the value is forced via an
argument; the difference with `CFLAGS=.. ./configure` is that the
latter is a bash-ism that may not survive. (theoretically speaking, if
something else has precedence over the environment variable value.)

### Sharing installed data between hosts

`make install` is `make install-exec` and `make install-data`. The
first installs platform-dependent and the second independent files. In
this way, multiple hosts can share data if they want.

### Cross-compilation

We have the options

- `--build`, the system which builds the package
- `--host`, the system that will run the package
- `--target`, only when building compiler tools; the output system

Simple cross-compilation only requires `--host`.

### Renaming binaries

Use `--program-prefix`, `--program-suffix`, and
`--program-transform-name`, e.g. might want to install `foo` as
`my-foo`.

## Autoconf

Autoconf has a lot of tools

- `autoreconf`, run all the autoconf tools in the right order
- `autoconf`, create `configure` from `configure.ac`
- `autoheader`, create `config.h.in` from `configure.ac`
- `autoscan`, scan sources for common portability problems and related
  macros missing from `configure.ac`
- `autoupdate`, update obsolete macros in `configure.ac`
- `ifnames`, gather identifiers from all `#if/def` preprocessor
  directives
- `autom4te`, heart of autoconf. Drives M4 and implements most
  features from above tools. Useful for more than `configure` files.
- `automake`, create `Makefile.in` from `Makefile.am` and `configure.ac`
- `aclocal`, scan `configure.ac` for third-party macros and craete
  `aclocal.m4`

The last two tools are part of GNU Automake.

### Autoreconf

Autoreconf takes `configure.ac` to produce `config.h.in` and
`Makefile.am` files to produce `Makefile.in` files.

These files are shell scripts with macro instructions, but often it's
only macro instructions. The macro processor is M4 (`man 1 m4`), and
autoconf offers some additional infrastructure and the pool of macros.

Example:

    # configure.ac
    
    # <Prelude>
    
    AC_INIT([mytest], [1.0], [bug-report@address]) # initialize autoconf
    AM_INIT_AUTOMAKE([foreign -Wall -Werror])      # initialize automake;
                                                   # check for tools needed by
                                                   # generated makefiles
    
    # <Check for programs>
    
    AC_PROG_CC                                     # check for a C compiler
    
    # <Check for libraries, headers, typedefs,
    # structs, compiler characteristics, library
    # functions>
    
    # <output files>
    
    AC_CONFIG_HEADERS([config.h])                  # declare output files
    AC_CONFIG_FILES([Makefile src/Makefile])       # declare output files
    AC_OUTPUT                                      # output declared files

    # Makefile.am
    SUBDIRS = src # recurse make here. the order is left-to-right; the current
                  # directory is built after these. Can be overriden with . as
                  # part of SUBDIRS

    # src/Makefile.am
    bin_PROGRAMS = hello   # PROGRAMS means we're building programs; bin means
                           # they will be installed to bindir. there's one program
                           # called 'hello'
    
    hello_SOURCES = main.c # to create 'hello' just compile 'main.c'

When initializing automake, the `foreign` option ignores some GNU
Coding Standards. `-Wall` turns on all warnings and `-Werror `converts
them to errors.

The `[]` are quotes; quoted strings are move further down the
processing and are very common; mistakes may occur without them.

The syntax is space sensitive.

### Generated files from `autoreconf -i`

- `aclocal.m4`, definitions for third-party macros used in `configure.ac`
- `depcomp`, `install-sh`, `missing`, auxiliary tools used during build
- `autom4te.cache`, autotools cache file

The former two are also distributed in the `.tar.xz` file.

### Defining macros

To define an m4 macro, use `AC_DEFUN`. Example:

    AC_DEFUN([NAME1], [Harry, Jr.])
    AC_DEFUN([NAME2], [Sally])
    AC_DEFUN([MET}, [$1 met $2])
    MET([NAME1], [NAME2])             # Harry, Jr. met Sally

There are certain macro namespaces:

- `m4_`, original `M4` macros and `M4sugar` macros
- `AS_`, `M4sh` macros, macroized shell constructs
- `AH_`, autoheader macros
- `AC_`, autoconf macros written on top of the above
- `AM_`, automake macros
- `AT_`, autotest macros

### Useful prelude macros

- `AC_INIT(PKG, VER, BUG-REPORT-ADDR)`, mandatory autoconf
  initialization
- `AC_PREREQ(VER)`, minimum autoconf version, e.g. `[2.65]`
- `AC_CONFIG_SRCDIR(FILE)`, safety check that distributed file exists,
  e.g. `src/main.c`
- `AC_CONFIG_AUX_DIR(DIRECTORY)`, where the aux scripts install-sh,
  depcomp, etc, will be placed, e.g. `[build-aux]`

### Useful program checks

`AC_PROG_*` with `CC, CXX, SED, YACC, LEX`, setting `$CC, $CXX, $SED,
$YAC, $LEX`, etc.

There is also `AC_CHECK_PROGS` for checking of an arbitrary program
(with alternatives). For example:

    AC_CHECK_PROGS([TAR], [tar gtar])
    if test "$TAR" = :; then
        AC_MSG_ERROR([This package needs tar.])
    fi

### Useful action macros

`AC_MSG_ERROR`, `AC_MSG_WARN`, print errors (also to
`config.log`). The former aborts configuration with an optional exit
status.

`AC_DEFINE(VAR, VAL, DESC)`, output

    /* DESC */
    #define VAR VAL

to `config.h`.

`AC_SUBST(VAR, [VAL])` replaces `@VAR@` with `VAL` in `Makefile.in`
and adds a `VAR = @VAR@` line. The latter can be prevented with
`AC_SUBST_NOTMAKE`. (automake 1.11+)

### Checking for libraries

`AC_CHECK_LIB(LIB, FUNC, [IF-FOUND], [IF-NOT])`, check if library
contains function. For example

    AC_CHECK_LIB(foo, bar, [FOOLIB=-lfoo])
    AC_SUBST([FOOLIB])

Then in linking we may use `$(FOOLIB)`.

If `[IF-FOUND]` is not passed, we have `LIBS="-lFOO $LIBS"` and
`#define HAVE_LIBFOO`.

### Checking for headers

    AC_CHECK_HEADERS([sys/params.h unistd.h])

may define `HAVE_SYS_PARAM_H` and `HAVE_UNISTD_H`.

### Output commands

Non-makefiles can be output with

    AC_CONFIG_FILES([script.sh:script.in])

which will process `script.in` to produce `script.sh`.

## Automake

The `Makefile.am` files follow roughly the same rules as Makefiles but
typically only contain variable definitions. `automake` creates build
rules from these definitions. Extra rules can be added, and will be
preserved.

### `Makefile.am` syntax

`option_where_CHOICE = targets`:

- `CHOICE` is one of `PROGRAMS, LIBRARIES, LTLIBRARIES, HEADERS,
  SCRIPTS, DATA`, telling that targets must be built as such.
- `where` is one of `bin, lib`, etc, corresponding to `$(bindir),
  $(libdir)` and so on.
- `opt` is optional; it is one of `dist, nodist`, signifying whether
  targets should be distributed or not.

There are also `target_CFLAGS` and so on that contain additional flags
to the default ones provided by `$(CFLAGS)`, which are e.g. `-g -O2`
if `CFLAGS` is not set.

In automake, non-alphanumeric characters are converted to `_`, for example

    bin_PROGRAMS = print run-me
    print_SOURCES = print.c print.h
    run_me_SOURCES = run.c run.h print.c

Automake automatically computes the list of objects to build and link
from targets and file lists. The headers are not compiled; they're
listed for distribution.

### Static libraries

`AC_PROG_RANLIB` should go in `configure.ac`

The `Makefile.am` should look like,

    lib_LIBRARIES = libfoo.a # must be named lib*.a
    libfoo_a_SOURCES = foo.c private_foo.h # headers not distributed
    include_HEADERS = foo.h # public header installed in $(includedir)

### Convenience libraries

These are non-installed libraries, e.g. smaller components that make
up a bigger library.

    noinst_LIBRARIES = libcompat.a
    libcompat_a_SOURCES = xalloc.c xalloc.h

In the `src/Makefile.am`, there would be

    LDADD = ../lib/libcompat.a
    AM_CPPFLAGS = -I$(srcdir)/../lib
    bin_PROGRAMS = foo
    foo_SOURCES = foo.c foo.h

### Build and source tree

The build tree, given by `$(builddir)`, contains the generated
Makefiles and object files. The `Makefile.am` and source files are in
the source tree given by `$(srcdir)`.

The source tree is used e.g. to pass `-I$(srcdir)/dir` to the compiler.

### Per-target flags

If `foo` is a program or library, we have `foo_FLAG` where `FLAG` is

- `CFLAGS`, C compiler flags
- `CPPFLAGS`, preprocessor flags such as `-I` and `-D`
- `LDADD`, link objects like `-l` and `-L` (where `foo` is a program)
- `LIBADD`, link objects like `-l` and `-L` (where `foo` is a library)
- `LDFLAGS`, additional linker flags

Note that `AM_FLAGS` and `target_FLAGS` cannot be overriden by the
user even if they specify `FLAGS=` in the configuration step.

### Distributed files

- sources declared with `SOURCES`
- headers declared with `HEADERS`
- scripts declared with `dist_..._SCRIPTS`
- data files declared with `dist_..._DATA`
- common files such as `ChangeLog`, `NEWS` and so on

For example, to additionally distribute `HACKING`, use

    # Makefile.am
    EXTRA_DIST = HACKING

### Conditional builds

One can use

    if WANT_BAR
        bin_PROGRAMS += bar
    endif

and so on, to control the build. `WANT_BAR` must be defined in
`configure.ac` with

    AM_CONDITIONAL(NAME, CONDITION)

which defines `NAME` if the shell instruction `CONDITION=` holds. For
example, to only include bar if `bar.h` is present in the system, use

    AC_CHECK_HEADER([bar.h], [use_bar=yes])
    AM_CONDITIONAL([WANT_BAR], [test "$use_bar" = yes])

## Libtool

### Shared libraries

The libtool archive `.la` abstracts the shared library format of
different systems, e.g. `libfoo.so` or `libfoo.dll`. In `Makefile.am`,
we simply create and link against `*.la` archives, which are properly
handled by libtool.

To enable libtool, in `configure.ac`

    LT_INIT([options]) # options are optional
                       # e.g. disable-shared or disable-static,
                       # that disables building those libraries
                       # by default; see also --enable-shared, etc

then in `Makefile.am`,

    lib_LTLIBRARIES = libfoo.a         # declare a libtool archive
    libfoo_la_SOURCES = foo.c foo.h
    ...
    runme_LDADD = libfoo.la

The libtool macros are necessary. The macros can be collected in a
directory, e.g. `m4`, configured in `configure.ac` with

    AC_CONFIG_MACRO_DIR([m4])

and later on in `configure.ac`, for example just before `LT_INIT()`,
one adds

    AM_PROG_AR() # enable weird lib tools from Microsoft

(This step is not necessary if `-Werror` is removed.)

Then in the `Makefile.am`, one uses

    ACLOCAL_AMFLAGS = -I m4 # options to pass to aclocal

### Wrapper scripts

Libtool also creates wrapper scripts, concealing the binaries
paths. The shell scripts can be executed, but to be debugged, for
example, one must use

    libtool --mode=execute gdb src/hello

Wrapper scripts find and execute binaries that are not yet
installed. This is useful e.g. for a test suite.

### Libtool interface numbers

Libtool libraries support a versioning system (that is separate from
releases). The versioning is technical, which means it cannot deviate
from fixed rules. It is thus reliable, and e.g. separate from release
versions which can be meaningless. (e.g. marketing-related.)

It is of the form `CURRENT[:REVISION[:AGE]]`.

These rules apply for releases only, not during the vcs development
stage, thus they must be adjusted in every release.

The rules are as follows:

1. Start with version information of `0:0:0` for each libtool library.
2. Update the version information only immediately before a public
   release of your software. More frequent updates are unnecessary,
   and only guarantee that the `current` interface number gets larger
   faster.
3. If the library source code has changed at all since the last
   update, then increment `revision` (`c:r:a` becomes `c:r+1:a`).
4. If any interfaces have been added, removed, or changed since the
   last update, increment `current`, and set `revision` to 0.
5. If any interfaces have been added since the last public release,
   then increment `age`.
6. If any interfaces have been removed or changed since the last
   public release, then set `age` to 0.
    
Never try to set the interface numbers so that they correspond to the
release number of your package. This is an abuse that only fosters
misunderstanding of the purpose of library versions.

## Gettext

_Internationalization_ is the act of modifying a program to support
multiple languages and other cultural habits. _Localization_ provides
the data necessary to support a new language or cultural
habit. They're abbreviated by the numeronyms i18n and l10n.

Internationalization is the programmers work while localization is the
translators work.

Gettext provides the language internationalization part. C files will
be modified as follows:

    #include <gettext.h>
    #define _(string) gettext(string)
    // ...
    puts(_("Hello world"));

### Internationalizing a package

1. Invoke `AM_GNU_GETTEXT` in `configure.ac`
2. Run `gettextize` to provide the basic infrastructure
3. Fill in the configuration files left by `gettextize`
4. Update `src/Makefile.am` to link e.g. `hello` with the necessary
   library
5. Update the code by initializing `gettext()` in `main()` and mark
   the translatable strings
6. Generate message catalogues

After entering

    AM_GNU_GETTEXT([external]) # use an external gettext; not from GNU libc

run

    gettextize --copy --no-changelog
    cp /usr/share/gettext/gettext.h src

The comamnd creates a `po` directory that will hold the message
catalogs. In `configure.ac`, one has (before `AC_OUTPUT`)

    AC_CONFIG_FILES([... po/Makefile.in])

which should be included in `SUBDIRS` of `Makefile.am`,

    SUBDIRS = po ...
    ACLOCAL_AMFLAGS = -I m4
    EXTRA_DIST = ...

Fill in `po/Makevars.template` and rename it as `po/Makevars`:

    DOMAIN = $(PACKAGE)
    subdir = po
    top_builddir = ...
    XGETTEXT_OPTIONS = --keyword=_ --keyword=N_
    COPYRIGHT_HOLDER = Your name or your emloyers
    MSGID_BUGS_ADDRESS = $(PACKAGE_BUGREPORT)  # third argument of AC_INIT
    EXTRA_LOCALE_CATEGORIES = ...

Source files that may contain translatable strings are listed in
`POTFILES.in`, one per line:

    src/main.c
    src/other.c

The `src/Makefile.am` should be updated to link to `$(LIBINTL)`.

    AM_CPPFLAGS = -DLOCALEDIR=\"$(localedir)\" # where the catalogs are
    # ...
    hello_SOURCES = ... gettext.h
    hello_LDADD = $(LIBINTL)

In `main()`, one must initialize the locale,

    #include <locale.h>
    // ...
    int main(void) {
      // The user can then use `LANG=fr_FR` to get the relevant messages.
      setlocale(LC_ALL, "");
      // tell gettext where to find the catalogs
      textdomain(PACKAGE);
      bindtextdomain(PACKAGE, LOCALEDIR);
      // ...
    }

We are ready to `autoreconf -i -m`, which will produce the template
message catalog file, which is `po/amhello.pot`. Updating it is costly
and typically occurs in `make distcheck`, or explicitly by `cd po &&
make update-po`.

### Add a new language

To add a new language, inspect the `po/PROJECT.pot` file. (where
`PROJECT` is the first argument of `AC_INIT`.)

There, `msgid` identifies a string and `msgstr` provides the
translation. The empty string is special; it is translated with
administrative information, as can be readily seen when inspecting the
`.pot` file.

To add a new language do the following:

    cd po
    msginit -l fr

Then edit the `fr.po` file created. The format `LL_CC.po` is also
supported; language code and country code. Replace the empty `msgstr`
with the translations and edit the header to have the right
information, e.g.

    "Content-Type: text/plain; charset=UTF-8\n"

Emacs' `po-mode` can help with the revision date; can be updated by
hitting `V`, which will also save the file and run `msgfmt
--statistics --check` that validates the po file.

Then, the language should be registered:

    printf "fr\n" >> LINGUAS

Finally one can test it with

    ./configure
    make
    cd po
    make update-po
    LANG=fr_FR.utf8 ../src/hello

For additional best practices and tips see
<https://www.lrde.epita.fr/~adl/autotools.html>. If for some reason
the translation does not appear, check the [gettext
FAQ](https://www.gnu.org/software/gettext/FAQ.html#integrating_noop).

## Nested packages

Arbitrary nesting is possible. The top configured package will
distribute configuration options to sub-packages. `./configure
--help=recursive` will show the help of all sub-packages.

Nested packages are regular directories.  In `Makefile.am`, `SUBDIRS`
must include them, and their directories must also be declared in
`configure.ac`

    AC_CONFIG_SUBDIRS([package-subdir])

so that `./configure` calls itself recursively.
