---
layout: post
title: Cube intersection algorithm
---
{% include mathjax.html %}

# A simple algorithm

Scroll to the end of the article for the Python code.

In this article I outline the derivation of a simple algorithm that
checks the intersection of two cubes of general position in
space. Programmers who are interested only in the algorithm should
read the definitions and the **checks**, marked with bold, skipping
the mathematical explanations.

If you wish to adapt these definitions to your program, you must take
care to correctly calculate the vectors involved. I use a certain
representation of the edge and face; the numbers involved will depend
on your representation of a cube. (For example, you may represent a
cube by its 8 vertices, or choose to represent it with a basepoint and
a 3-frame, or some other representation.)

A word of warning: I wrote this article for anyone who is interested
in writing a cube intersection algorithm. I have not researched how it
holds up in terms of performance when compared to other algorithms. I
also have not researched its numerical stability properties.

## Problem statement

Assume we're given two cubes $Q_1, Q_2$ of general position (i.e. not
axis-aligned) in three-dimenisonal space. Write an algorithm that
asserts whether they intersect or not.

## Solution

One solution is to check that no edge of the first cube intersects
with a face of the second. There are 12 edges and 6 faces, and so
there will be at most 72 such checks.

Thus we need a function $I(E, F)$, that checks whether an edge $E$
intersects with a face $F$.

This operation is costly, but we can optimize by only checking when
necessary: if $d$ is the distance of the centers of the cubes, and
$s_1$ and $s_2$ their corresonding side lengths, then we have the
following three cases:

1. If $d > \sqrt 3 (s_1 + s_2) / 2$ then the cubes are too far to
   intersect. (the [circumscribed
   spheres](https://en.wikipedia.org/wiki/Circumscribed_sphere) do not
   intersect.)
2. Else, if $d \leq (s_1 + s_2) / 2$ then the cubes are too close;
   they intersect. (the [inscribed
   spheres](https://en.wikipedia.org/wiki/Inscribed_sphere)
   intersect.)
3. Otherwise perform the edge-face intersection checks described
   below.

### Edge-Face intersection

Suppose we're given an edge $V_U$ and a face $(Y, Z)_X$.

(By these notations we mean the following: the edge has vertices $U$
and $U + V$, and the face has vertices $X$, $X + Y$, $X + Z$, and $X +
Y + Z$, and one can think of $U$ and $X$ as basepoints.)

### The affine line-plane intersection equation

If they intersect, then we must have a unique solution in $\lambda,
\alpha, \beta$, all real numbers, of the equation

$$U + \lambda V = X + \alpha Y - \beta Z$$

The above equation solves for the intersection of the affine line
spanned by the edge and the affine plane spanned by the face. Once we
have it, we need additional checks to verify that the point lies both
inside the edge and inside the face.

#### Obtaining the point of intersection

We now manipulate the above by taking a dot-product with the normal
vector $N$ to the face, to obtain

$$U\cdot N + \lambda V\cdot N = X\cdot N$$

(where the eliminations happened because $N$ is perpendicular to $Y$
and $Z$)

Thus we can solve for $\lambda$, but first we must verify that the
denominator is not zero:

**(check 1)** We verify that $V\cdot (Y\times Z) \not = 0$.

Finally the solution for $\lambda$ is:

$$\lambda = \frac{(X - U)\cdot N}{V\cdot N}.$$

We can now write the point of intersection of the line and plane, by
substituting $\lambda$ in the right-hand-side of the line-plane
equation.

$$I = U + \frac{(X - U)\cdot (Y\times Z)}{V\cdot (Y\times Z)}V,$$

where we replaced $N$ by its definition $(Y\times Z) / \|Y\times Z\|$
and noticed that the denominators cancel out.

#### Verifying that the intersection occurs inside the edge

We can now check that the intersection occurs inside the edge:

**(check 2)** We verify that $0 \leq \frac{(X - U)\cdot (Y\times Z)}{V\cdot (Y\times Z)} \leq 1$.

#### Verifying that the intersection occurs inside the plane

We must calculate $\alpha$ and $\beta$ and verify that $0 \leq \alpha
\leq 1$ and $0 \leq \beta \leq 1$.

To calculate these two coefficients, we must write the vector $I - X$
as a linear combination of $Y$ and $Z$. (as seen from the line-plane
equation.) Let $M$ by the matrix with columns $Y, Z, N$. To write $I -
X$ as a linear combination of $Y, Z, N$, we must solve

$$M\begin{pmatrix}\alpha \\\beta \\\gamma\end{pmatrix} = I - X,$$

and by multiplying by the inverse matrix $M^{-1}$ we obtain

$$\begin{pmatrix}\alpha \\\beta \\\gamma\end{pmatrix} = M^{-1}(I - X).$$

In the above, we already know that $\gamma = 0$ since the point $I$
lies on the affine plane spanned by the face. Thus, we do not need to
calculate the bottom row of $M^{-1}$. The [formula for inverting a 3x3
matrix](https://en.wikipedia.org/wiki/Invertible_matrix#Inversion_of_3_%C3%97_3_matrices)
like $M$ is

$$M^{-1} = \begin{pmatrix}Y & Z & N\end{pmatrix}^{-1} = \frac 1 {\|Y\times Z\|}\begin{pmatrix}(Z\times N)^t \\ (N\times Y)^t \\ (Y\times Z)^t\end{pmatrix}.$$

Thus we obtain $\alpha$ and $\beta$:

$$\alpha = \|Y\times Z\|^{-1}(Z\times N)\cdot(I - X),$$

$$\beta = \|Y\times Z\|^{-1}(N\times Y)\cdot(I - X).$$

What we really want to do now is finish by checking the boundary
conditions on $\alpha$ and $\beta$. By substituting $N$ with $Y\times
Z / \|Y\times Z\|$ we get

$$0 \leq (Z\times (Y\times Z)) \cdot (I - X) \leq \|Y \times Z\|^2,$$

$$0 \leq ((Y\times Z)\times Y) \cdot (I - X) \leq \|Y \times Z\|^2.$$

We may rewrite the triple cross products, by replacing $I$ with its
calculation:

**(check 3)** Verify that the two inequalities hold:

$$0 \leq (Z\times (Y\times Z)) \cdot (U - X + \frac{(X - U)\cdot (Y\times Z)}{V\cdot (Y\times Z)}V) \leq \|Y \times Z\|^2,$$

$$0 \leq ((Y\times Z)\times Y) \cdot (U - X + \frac{(X - U)\cdot (Y\times Z)}{V\cdot (Y\times Z)}V) \leq \|Y \times Z\|^2.$$

#### The result of $I(E, F)$

Thus, the function $I(E, F)$ that evaluates whether the edge $E$
intersects the face $F$ is defined as follows:

    If any of check 1, 2, 3 is false, return false; else return true.

## Further optimizations

### Reducing the edge-face intersection calls

We may reduce the 72 calls to $I(E, F)$ to at most 9, because we only
have to check the edge-face intersection over the three edges of $Q_1$
closest to the center of $Q_2$ and the three faces of $Q_2$ closest to
the center of $Q_1$.

We actually implement this optimization in the Python code below.

### Using less coordinates to represent the cubes

We may "pack" the representation of a cube to only $7$ real numbers
instead of $24$ by using a side length, a base point and a 3-frame,
also known as an element of $SO(3)$. See [Charts on
$SO(3)$](https://en.wikipedia.org/wiki/Charts_on_SO(3)) for formulas
and information.

This is not implemented in the Python code below.

## The Python implementation

The [`attrs`](https://www.attrs.org/en/stable/) package is only used
to make Python classes easier to work with.

```python
from array import array
from attrs import define
from math import sqrt
from numpy import argmax, add, array_equal, subtract, multiply, dot, cross
from numpy.linalg import norm

@define
class Edge:
    # directed from a to b
    #
    # a -> b
    #
    a: array('f') # float[3]
    b: array('f') # float[3]

@define
class Face:
    # counter-clockwise
    #
    # d -- c
    # |    |
    # a -- b
    #
    a: array('f') # float[3]
    b: array('f') # float[3]
    c: array('f') # float[3]
    d: array('f') # float[3]

@define
class Cube:
    # A cube looks like this
    #
    # h -- g
    # |    |    North face
    # e -- f
    #
    # d -- c
    # |    |    South face
    # a -- b
    #
    a: array('f') # float[3]
    b: array('f') # float[3]
    c: array('f') # float[3]
    d: array('f') # float[3]
    e: array('f') # float[3]
    f: array('f') # float[3]
    g: array('f') # float[3]
    h: array('f') # float[3]

# Return the 6 faces of the cube
def get_faces(r: Cube):
    return [Face(r.a, r.b, r.c, r.d), # S
            Face(r.a, r.e, r.h, r.d), # W
            Face(r.b, r.c, r.g, r.f), # E 
            Face(r.e, r.f, r.g, r.h), # N
            Face(r.a, r.b, r.f, r.e), # front
            Face(r.d, r.c, r.g, r.h)] # back

# Return the 12 edges of the cube
def get_edges(r: Cube):
    return [Edge(r.a, r.b),
            Edge(r.b, r.c),
            Edge(r.c, r.d),
            Edge(r.d, r.a),
            Edge(r.e, r.f),
            Edge(r.f, r.g),
            Edge(r.g, r.h),
            Edge(r.h, r.e),
            Edge(r.a, r.e),
            Edge(r.d, r.h),
            Edge(r.b, r.f),
            Edge(r.c, r.g)]

def get_side(r: Cube):
    return norm(subtract(r.a, r.b))

def get_center(r: Cube):
    return add(r.a, multiply(.5, subtract(r.g, r.a)))

def edge_face_intersect(edge: Edge, face: Face):
    u = edge.a
    v = edge.b
    x = face.a
    y = subtract(face.b, face.a)
    z = subtract(face.d, face.a)
    c = cross(y, z)

    t1 = dot(v, c)
    if t1 == 0:
        return False

    t2 = dot(subtract(x, u), c) / t1
    if t2 < 0 or t2 > 1:
        return False
    
    i = add(u, multiply(r, v))
    ix = subtract(i, x)

    norm_squared = dot(c, c)
    t3 = dot(cross(z, c), ix)
    if t3 < 0 or t3 > norm_squared:
        return False
    t4 = dot(cross(c, y), ix)
    if t4 < 0 or t4 > norm_squared:
        return False
    
    return True

# return the vertex of the cube `r` closest to `p`
def apex(r: Cube, p: array('f')):
    x = subtract(p, get_center(r))
    t1 = dot(subtract(r.b, r.a), x)
    t2 = dot(subtract(r.d, r.a), x)
    t3 = dot(subtract(r.e, r.a), x)
    if t1 >= 0:
        if t2 >= 0:
            if t3 >= 0:
                return r.g
            else:
                return r.c
        else:
            if t3 >= 0:
                return r.f
            else:
                return r.b
    else:
        if t2 >= 0:
            if t3 >= 0:
                return r.h
            else:
                return r.d
        else:
            if t3 >= 0:
                return r.e
            else:
                return r.a

# return the 3 neighbors of the vertex `v` in the cube `r`
#
# The result frame is positively oriented, see the right-hand rule
# <https://en.wikipedia.org/wiki/Right-hand_rule>.
def neighbors(r: Cube, v: array('f')):
    if array_equal(v, r.a):
        return [r.b, r.d, r.e]
    elif array_equal(v, r.b):
        return [r.c, r.a, r.f]
    elif array_equal(v, r.c):
        return [r.g, r.d, r.b]
    elif array_equal(v, r.d):
        return [r.h, r.a, r.c]
    elif array_equal(v, r.e):
        return [r.f, r.a, r.h]
    elif array_equal(v, r.f):
        return [r.g, r.b, r.e]
    elif array_equal(v, r.g):
        return [r.h, r.c, r.f]
    elif array_equal(v, r.h):
        return [r.e, r.d, r.g]

def get_edges(r: Cube, p: array('f')):
    a = apex(r, p)
    frame = neighbors(r, a)
    return [Edge(a, frame[0]),
            Edge(a, frame[1]),
            Edge(a, frame[2])]

def get_faces(r: Cube, p: array('f')):
    a = apex(r, p)
    frame = neighbors(r, a)
    return [Face(a, frame[0], subtract(add(frame[0], frame[1]), a), frame[1]),
            Face(a, frame[0], subtract(add(frame[0], frame[2]), a), frame[2]),
            Face(a, frame[1], subtract(add(frame[1], frame[2]), a), frame[2])]

def intersect(r: Cube, s: Cube):
    d = norm(subtract(get_center(r), get_center(s)))
    t = (get_side(r) + get_side(s)) / 2
    if d > sqrt(3) * t:
        return False
    elif d <= t:
        return True
    else:
        c1 = get_center(r)
        c2 = get_center(s)
        edges = get_edges(r, c2)
        faces = get_faces(s, c1)
        for edge in edges:
            for face in faces:
                if edge_face_intersect(edge, face):
                    return True
        return False

def start():
    xs = [[0., 0., 0.],
          [1., 0., 0.],
          [1., 1., 0.],
          [0., 1., 0.],
          [0., 0., 1.],
          [1., 0., 1.],
          [1., 1., 1.],
          [0., 1., 1.]]
    r = Cube(*xs)
    s1 = Cube(*subtract(xs, [0.9, .9, .9]))
    s2 = Cube(*subtract(xs, [1.1, 1.1, 1.1]))
    print("The cubes r and s1 intersect: ", intersect(r, s1))
    print("The cubes r and s2 intersect: ", intersect(r, s2))
```
