---
layout: post
title: Accessing a restricted file on Linux and BSD
---

# Introduction

Suppose you'd like as a regular user to have access to a particular file that is normally restricted. For example, perhaps you'd like have read access to `/dev/sdb`. There are three solutions I can think of:

1. Log in as root and access it this way.
2. Add your regular user to the group the file belongs to. 
3. Use an Access Control List.

The first solution can be problematic because the programs involved might be not trusted. The second solution has the drawback of granting the user access to all the files that belong to that group. The last solution is much more precise and does exactly what we require it to do.

## Using group permissions

Suppose that we have a file called `foo`. First, find the group by using `ls -l foo | cut -d " " -f 4`, which let's assume is `disk`. Then add the user to the `disk` group (the method varies depending on the distribution). Log in again using `su -l <user>` to refresh the groups the user is in. Do the work that you need with the file `foo` and finally remove the user from the `disk` group (the method varies depending on the distribution).

## Using ACLs

Suppose then that we have a file called `foo`

```
root # touch foo 
root # chmod 600 foo
```

and we would like to user user `penguin` access to it. We will create a file called `oldpermissions` that will allow us to restore access rights at the end of this blog post.

```
root # getfacl foo > oldpermissions
```

Then we grant the user read and write access:

```
root # setfacl -m u:penguin:rw- foo
```

We can confirm this:

```
root # su penguin
penguin $ echo 'hello world' > foo
penguin $ cat foo
hello world
```

Finally, to restore the permissions:

```
root # setfacl --restore=oldpermissions
root # rm oldpermissions
```
