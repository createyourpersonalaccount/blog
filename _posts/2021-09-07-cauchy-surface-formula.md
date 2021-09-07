---
layout: post
title: Cauchy's surface formula
---
{% include mathjax.html %}

# The formula

Let $K\subset\mathbb R^n$ be a convex body with boundary $\partial K$ and choose uniformly a random unit vector $e$. Let $K^\bot_e$ denote the projection of $K$ to the hyperplane that is perpendicular to $e$. Let $\operatorname{Area}(A)$ denote the surface area of an $(n-1)$-dimensional surface. Then we have

$$
\begin{align}
\label{eq:cauchysformula}
\operatorname{Area}(\partial K) = 2 \mathbb E[\operatorname{Area}(K^\bot_e)]. 
\end{align}
$$

# Proof[^1]

Fix a unit vector $e$. Let $[0,e] \subset \mathbb R^n$ denote the segment with endpoints the origin and $e$. Using convexity and Cavalieri's principle, we have

$$
\begin{align}
\label{eq:cavalieri-principle}
\operatorname{Area}(K^\bot_e) = \frac 12\operatorname{Volume}(\partial K + [0,e]). 
\end{align}
$$

We wish to make use of this observation.

For a set $A \subset \mathbb R^{n-1}\times \{0\}$ we have

$$
\begin{align}
\mathbb E[\operatorname{Volume}(A + [0,e])] = \operatorname{Area}(A).
\end{align}
$$

This is obvious from Cavalieri's principle since we have $\operatorname{Volume}(A + [0,e]) = \operatorname{Area}(A)$ almost surely. Thus for the surface $\Sigma$ of a polytope and $\delta > 0$ small, we conclude

$$
\begin{align}
\mathbb E[\operatorname{Volume}(\Sigma + [0,\delta e])] = \delta\operatorname{Area}(\Sigma) + o_\Sigma(\delta). 
\end{align}
$$

Divide by $\delta$ and use \eqref{eq:cavalieri-principle} on the left hand side for a sequence of convex polytopes converging to $K$ and a sequence of $\delta$ converging to $0$ fast enough to conclude the proof.

[^1]: Tsukerman E. and Veomett E., A Simple Proof of Cauchy's Surface Area Formula, [arXiv:1604.05815](https://arxiv.org/abs/1604.05815) [math.DG]
