---
layout: post
title: A Geometric Interpretation of the Fourier Transform
---
{% include mathjax.html %}

# Introduction

Today I came across an idea that has alluded me in the past. I was studying the second chapter of [An Introduction to X-Ray Crystallography by M. M. Woolson](https://www.cambridge.org/core/books/an-introduction-to-xray-crystallography/4C99F07B3106935F7FE1AF40388B53D1) where the general mathematics of scattering are investigated. I will spare you all the fascinating details and only concentrate on my point, but I recommend the subject if you are interested in the various aspects of the Fourier transform.

## A travelling phase

Imagine that a complex phase is travelling on the straight line segment connecting the origin $O$ and a point $P$. It starts at $P$ with the value $1$ and travels along the straight line in unit speed, while rotating with angular velocity $\omega$. At time $t$, we find the phase to be $e^{i\omega t}$. Moving at unit speed, it reaches the origin $O$ exactly in $r = \|OP\|$ time; thus it reaches the origin with the value $e^{i\omega r}$.

## The interpretation of the dot product

Now let $x\in\mathbb{R}^n$ be the position of the point $P$ under consideration. In the Fourier transform, the phase $e^{-2\pi i x\cdot\xi}$ is involved. Here the negative sign is in fact on $x$; the vector $-x$ is the vector starting from $P$ pointing back at the origin. The vector $\xi$ is the wave vector and contains the direction of travel of the plane wave. Plane waves arise as special solutions of the source-free wave equation (see § 5.5 of [Advanced Classical Electromagnetism by R. M. Wald](https://press.princeton.edu/books/hardcover/9780691220390/advanced-classical-electromagnetism).) Their form is $Ce^{i(x\cdot\xi - \omega t)}$ for given $C\in\mathbb{C}$ and $\omega\in\mathbb{R}$. They are travelling in the direction of $\xi$ with velocity $\omega/\|\xi\|$. (For electromagnetic waves, $\omega = c\xi$.)

If we imagine that the point $P$ emits a plane wave at time $t = 0$ starting with phase $1$ in the direction $\xi$ with angular velocity $\omega$, its value when it meets the origin is going to be $e^{-i\omega x\cdot\xi}$. Typical values for $\omega$ are $1$ and $2\pi$.

## Superposition of phases

In the general case, if we have a distribution of points $\rho$, then by starting travelling plane waves with phase $1$ in the direction $\xi$ of each point $x$ with $\rho(x)\not=0$, while true that each wave will meet the origin at different times, the total effect of the received waves will be the sum of their amplitudes and phases, and so we arrive at the expression

\begin{align}
\widehat{\rho}(\xi) := \int e^{-2\pi i x\cdot\xi}\rho(x)dx.
\end{align}

## The inverse Fourier transform

The inverse transformation makes just as much sense! Now, we are trying to reconstruct the point distribution by looking at the sum of all plane waves received from the origin and sending them back. Hence, we now consider the forward vector $+x$ which points from the origin $O$ to $P$. By the exact reverse situation, $e^{2\pi i x\cdot\xi}$ is the phase send back to $P$ from $O$ for the particular frequency $\xi$; adding up all the frequencies gives the expression

\begin{align}
\rho(x) = \int e^{2\pi i x\cdot\xi}\widehat{\rho}(\xi)d\xi
\end{align}

## An example: the Dirac measure

The Dirac delta has Fourier transform $\widehat{\delta}(\xi) = 1$ for all $\xi$. This makes sense: any phase emitted from the origin is received by the origin instantaneously, thus only the value $1$ is captured, and this explains the Fourier transform. The inverse Fourier transform also makes sense: to determine it at $x$, we send out every possible frequency, which cancel each other at every $x$ except for $x=0$.

## More general phases

There is room in the above interpretation for more general phases. We can imagine that there is reason for which the travelling phase behaves differently when changing $x$ or $\xi$. The most general form we can consider is the integral

\begin{align}
\int e^{i\varphi(x,\xi)} u(x, \xi)dx.
\end{align}

Such integrals are considered in the theory of [Fourier Integral Operators](https://en.wikipedia.org/wiki/Fourier_integral_operator).
