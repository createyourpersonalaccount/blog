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
a diagonal.)

A word of warning: I wrote this article for anyone who is interested
in writing a cube intersection algorithm. I have not researched how it
holds up in terms of performance when compared to other algorithms. I
also have not researched its numerical stability properties.

## Problem statement

Assume we're given two cubes $Q_1, Q_2$ of general position (i.e. not
axis-aligned) in three-dimenisonal space. Write an algorithm that
asserts whether they intersect or not.

Assume that neither of the cubes contains the other fully.

## Solution

One solution is to check that no edge of the first cube intersects
with a face of the second. There are 12 edges and 6 faces, and so
there will be at most 72 such checks.

Thus we need a function $I(E, F)$, that checks whether an edge $E$
intersects with a face $F$.

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

**(check 2)** We verify that $0 \leq (X - U)\cdot (Y\times Z) \leq V\cdot (Y\times Z)$.

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

One minor optimization is by reducing the 72 $I(E, F)$ checks to a
smaller number; this might be possible by first verifying that no
vertex of the first cube lies inside the other cube, which implies
that there will be at two faces intersecting the culprit edge.

## The Python implementation

The [`attrs`](https://www.attrs.org/en/stable/) package is only used
to make Python classes easier to work with.

```python
from array import array
from attrs import define
from numpy import add, subtract, dot, cross

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

def edge_face_intersect(edge: Edge, face: Face):
    u = edge.a
    v = edge.b
    x = face.a
    y = subtract(face.b, face.a)
    z = subtract(face.d, face.a)
    c = cross(x, y)

    t1 = dot(v, c)
    if t1 == 0:
        return False

    t2 = dot(subtract(x, u), c)

    if t2 < 0 or t2 > t1:
        return False
    
    i = add(u, multiply(t2 / t1, v))
    ix = subtract(i, x)

    norm_squared = dot(c, c)
    t3 = dot(cross(z, c), ix)
    if t3 < 0 or t3 > norm_squared:
        return False
    t4 = dot(cross(c, y), ix)
    if t4 < 0 or t4 > norm_squared:
        return False
    
    return True

def intersect(r: Cube, s: Cube):
    edges = get_edges(r)
    faces = get_faces(s)
    for edge in edges:
        for face in faces:
            if edge_face_intersect(edge, face):
                return True
    return False
```
