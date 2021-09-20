---
layout: post
title: Taylor expansion of the Riemannian volume form
---
{% include mathjax.html %}

# The question

Let $(M,g)$ be a [Riemannian manifold](https://en.wikipedia.org/wiki/Riemannian_manifold) of dimension $n\in\mathbb N$. What is the Taylor expansion of the volume of a small ball around a point as a function of its radius?

The answer, at least up to the first nontrivial term, is:

$$
\begin{align}
\operatorname{vol}(B(x,r)) = \omega_n(r^n - \frac 1{6(n+2)}\operatorname{Sc}(x)r^{n+2}) + O(r^{n+4}),
\end{align}
$$

where $\operatorname{Sc}(x)$ is the [scalar curvature](https://en.wikipedia.org/wiki/Scalar_curvature) at the point $x$ and $\omega_n$ is the volume of the unit ball of $\mathbb{R}^n$.

# The proof

We prove this result by using normal coordinates around $x$. Let $v$ be any nonzero vector and define the path $\gamma(t) := tv$. Pick a vector $w$ and consider the vector field $J(t) := tw$ on $\gamma(t)$. It turns out that this vector field is a [Jacobi vector field](https://en.wikipedia.org/wiki/Jacobi_field), so it satisfies the equation

$$
\begin{align}
J''(t) + R(\gamma(t), J(t))\gamma(t) = 0,
\end{align}
$$

where $R$ is the [Riemannian curvature tensor](https://en.wikipedia.org/wiki/Riemann_curvature_tensor). Using this equation, we may compute second-order Taylor expansion of the function

$$
\begin{align}
t \mapsto g_{\gamma(t)}(J(t), J(t)),
\end{align}
$$

and the result is

$$
\begin{align}
t^2 g_{tv}(w,w) = t^2\delta_{ij}w^iw^j - \frac{t^4}3 R_{iklj}v^kv^l w^iw^j + O(t^6).
\end{align}
$$

This implies

$$
\begin{align}
\label{eq:metricexpansion}
g_v = \delta - \frac 13 R_{iklj} v^kv^l + O(v^4).
\end{align}
$$

For a matrix $A$, we have

$$
\begin{align}
\label{eq:matrixexpansion}
\det(I - A) = 1 - \operatorname{tr}A + O(A^2),
\end{align}
$$

and taking determinants in \eqref{eq:metricexpansion} and then applying \eqref{eq:matrixexpansion} for $A_{ij} = \frac 13 R_{iklj}v^kv^l$ we obtain

$$
\begin{align}
\sqrt{\det g} = 1 - \frac 16 R_{kl}v^kv^l + O(v^4),
\end{align}
$$

where $R_{kl} = R^i_{kli}$ is the [Ricci curvature tensor](https://en.wikipedia.org/wiki/Ricci_curvature). It follows that for small $r$, we have

$$
\begin{align}
\operatorname{vol}(B_r(0)) = \omega_n(r^n - \frac 1{6(n+2)}\operatorname{Sc}(0)r^{n+2}) + O(r^{n+4}),
\end{align}
$$

where $\operatorname{Sc}(0)$ is the scalar curvature at $0$ and $\omega_n$ is the volume of the unit ball of $\mathbb{R}^n$ (see the [next lemma](#lemma). This result does not depend on the choice of coordinates unlike the previous expansion.

## Lemma {#lemma}

For any square $n\times n$ matrix $A$ and $n$-dimensional ball of radius $r>0$ at the origin $B(r)$, we have

$$
\begin{align}
\int_{B(r)} \langle Ax, x\rangle dx
& = \frac{1}{n+2}\operatorname{tr}(A) \cdot \operatorname{vol}(B(1))\cdot r^{n+2}.
\end{align}
$$

### Proof

The off-diagonal terms cancel by the symmetry of the domain of integration, 

$$
\begin{align}
\int_{B(r)} \langle Ax, x\rangle dx
& = \sum_{i=1}^n\int_{B(r)} A_{ii} (x^i)^2 dx \\
& = r^{n+2}\sum_{i=1}^n A_{ii} \int_{B(1)} (x^i)^2 dx.
\end{align}
$$

Using Folland[^1] (or simply integrating this expression), we obtain

$$
\begin{align}
\int_{B(1)} (x^i)^2dx
& = \frac{1}{n+2}\cdot 2\frac{\Gamma(3/2)\Gamma(1/2)^{n-1}}{\Gamma(\frac{n+2}2)} \\
& = \frac{1}{n+2}\cdot \operatorname{vol}(B(1)).
\end{align}
$$

# Jacobi fields

A Jacobi field is the derivative in the parameter $\tau$ of a parametrized family of geodesics $\gamma_\tau(t)$. Using normal coordinates $U$, the vector field

$$
\begin{align}
(x,\xi) = (tv, tw)
\end{align}
$$

for $v\in U$ and $w\in\mathbb{R}^n$ is a Jacobi field for small $t$.

[^1]: Folland, Gerald B. How to integrate a polynomial over a sphere. Amer. Math. Monthly 108 (2001), no. 5, 446--448.
