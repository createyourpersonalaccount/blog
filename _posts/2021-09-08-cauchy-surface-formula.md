---
layout: post
title: Cauchy's surface formula
---
{% include mathjax.html %}

# The formula

Let $K\subset\mathbb R^n$ be a convex body with boundary $\partial K$ and choose uniformly a random unit vector $e$. Let $K^\bot_e$ denote the projection of $K$ to the hyperplane that is perpendicular to $e$. Then we have

$$
\begin{align}
\label{eq:cauchysformula}
\mathbb E[|K^\bot_e|] = \frac {\mathbb E[|\sin\theta|]}2 |\partial K| 
\end{align}
$$

where $\theta$ is the angle $e$ makes the $x_1$-axis of $\mathbb R^n$.

# Proof[^1]

Fix a unit vector $e$ and let $\delta > 0$. Let $[0,e] \subset \mathbb R^n$ denote the segment with endpoints the origin and $e$.

For a subset $A$ of an affine hyperplane, we have

$$
\begin{align}
\mathbb E[|A + [0,\delta e]|] = \delta |\sin\theta| |A|,
\end{align}
$$

where $\theta$ is the angle formed by $e$ and the hyperplane. On the other hand, by [Cavalieri's principle](https://en.wikipedia.org/wiki/Cavalieri%27s_principle), 

$$
\begin{align}
\mathbb E[|A + [0,\delta e]|] = \delta |A^\bot_e|,
\end{align}
$$

Thus for the surface $\Sigma$ of a finite convex polytope, we conclude

$$
\begin{align}
\delta |\Sigma| \mathbb E[|\sin\theta|] = 2\delta|\Sigma^\bot_e| + o_\Sigma(\delta). 
\end{align}
$$

Divide by $\delta$ and use a sequence of convex polytopes converging to $K$ and a sequence of $\delta$ converging to $0$ fast enough to conclude the proof.

[^1]: The proof is taken from: Tsukerman E. and Veomett E., A Simple Proof of Cauchy's Surface Area Formula, [arXiv:1604.05815](https://arxiv.org/abs/1604.05815) [math.DG]

