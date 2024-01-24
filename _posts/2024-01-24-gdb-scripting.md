---
layout: post
title: GDB scripting
---

# GDB Scripting

If you're thinking of using Guile instead of Python, *don't*. Guile is a great language, but don't use it for gdb scripting, the gdb community doesn't use it. If you're thinking of using gdbscript, *don't*. It's powerless. With that out of the way, let's begin:

Site-wide, gdb uses _data-directory_ for its Python scripts, which can be examined from within gdb with:

    show data-directory

Under the `data-directory/python` directory you will find Python scripts that e.g. pretty-print C++ strings, and that gdb makes use of automatically when debugging C++.

Normally you don't have to touch this site-wide directory, and instead you use the `source` command, which you can either put in your project's gdbinit files and run as:

    gdb -x my_gdbinit_project_file

or use interactively:

    source my_command.py

Side note: There is good advice online about builting custom CLI scripts that load various configurations for your specific project, and this may be a good idea for debugging too. See the external resource [Building a CLI for Firmware Projects using Invoke](https://interrupt.memfault.com/blog/building-a-cli-for-firmware-projects). This way you can launch a particular debugging configuration very easily.

We can python interactively with the `python-interactive` command (the `gdb` module is already imported):

    # ... get gdb to some state where there's a backtrace ...
    my_frame = gdb.newest_frame()
    my_val_object = my_frame.read_val("var_name")
    str(my_val) # obtain the string representing the value of `var_name`

We can define our own gdb functions, in this case `my_function()`, with this:

```python
import gdb

class MyClass (gdb.Command):
    def __init__(self):
        # the name of the function is here
        super(MyClass, self).__init__("my_function", gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        # code goes here
        print("Hello world")

MyClass()
```

Time to explore the above in a project. Let's write a recursive tree walker function, and our task is to unwind the frames to print all the paths the function went through to reach a leaf.

```C++
#include <iostream>
#include <list>
#include <numeric>
#include <vector>

template <typename T> struct Node {
  std::vector<Node<T>> children;
  T value;
  std::vector<T> collect_leaves() const {
    if (children.empty()) {
      return std::vector<T>{value};
    } else {
      std::vector<T> acc;
      for(auto child : children) {
        auto v = child.collect_leaves();
        acc.insert(acc.end(), v.begin(), v.end());
      }
      return acc;
    }
  }
};

int main(void) {
  /* The tree looks like this:
         1
      /  |  \
     2   3   4
         |
         5
   */
  Node<int> n1, n2, n3, n4, n5;
  // this nonsense is done because I hit a Liquid formatter bug on GH pages
  n1.value = 1; n2.value = n2; n3.value = n3; n4.value = n4; n5.value = n5; 
  n1.children.push_back(n2);
  n1.children.push_back(n3);
  n1.children.push_back(n4);
  n1.children[1].children.push_back(n5);
  for (auto b : n1.collect_leaves()) {
    std::cout << b << std::endl;
  }
  return 0;
}
```

We use the following python gdb script:

```python
import gdb

class RecursiveParameters (gdb.Command):
    def __init__(self):
        super(RecursiveParameters, self).__init__("recursive_parameters", gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        del arg, from_tty
        frame = gdb.newest_frame()
        parameters = []
        while(frame):
            try:
                x = frame.read_var("this").dereference()
                value = str(x['value'])
                parameters = [value] + parameters
            except ValueError:
                pass
            frame = frame.older()
        print(parameters)

RecursiveParameters()
```

and we compile with `-ggdb g3`. Behold the following gdb session:

```
$ gdb walk_tree
Reading symbols from walk_tree...
(gdb) source recursive_parameters.py
(gdb) b 11
Breakpoint 1 at 0x189d: file walk_tree.cpp, line 11.
(gdb) commands
Type commands for breakpoint(s) 1, one per line.
End with a line saying just "end".
>silent
>recursive_parameters()
>continue
>end
(gdb) r
Starting program: walk_tree
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
['1', '2']
['1', '3', '5']
['1', '4']
2
5
4
[Inferior 1 (process 233230) exited normally]
```

We put a breakpoint just before `collect_leaves()` returns from a leaf, and using `commands` we entered a small script that calls our python function to unwind the stack and show the three paths taken, `[1, 2]`, `[1, 3, 5]`, and `[1, 4]`.

## Some useful projects

There are quite a few projects that script and enhance gdb. You may enjoy:

- [vdb](https://github.com/PlasmaHH/vdb)
- [gef](https://github.com/hugsy/gef)
- [pwndbg](https://github.com/pwndbg/pwndbg)

but I prefer for now to write my own scripts, as it facilitates learning. The simpler project [gdb-dashboard](https://github.com/cyrus-and/gdb-dashboard) just displays a lot of useful information (and can be customized.) I prefer that to gdb's tui or plain gdb.
