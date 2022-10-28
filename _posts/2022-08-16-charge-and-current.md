---
layout: post
title: Charge and Current
---
{% include mathjax.html %}

# Introduction

This post is about
[electromagnetism](https://en.wikipedia.org/wiki/Electromagnetism) and
the [continuity
equation](https://en.wikipedia.org/wiki/Continuity_equation).

While studying electromagnetism from [Giancoli's
book](https://www.pearson.com/en-us/search.html?q=Giancoli%20Physics%20Principles%20with%20Applications)
I encountered the concepts of _charge density_ $\rho$ and _current
density_ $\vec{j}$. The charge density is a signed quantity that gives
the infinitesimal charge at $x$ in time $t$, while the current density
is a vector that denotes the infinitesimal velocity of that
infinitesimal charge, multiplied by the charge itself. (a kind of
momentum.)  Suddenly I wondered why is it that $\vec{j}$ cannot be
derived by $\rho$?

This conviction was based on the discrete situation, where a single
charge $q$ is given by its position $x(t)$, and then $\vec j$ is equal
to $q x'(t)$.

However, the continuous case is not as apparent! Naive attempts such
as $\vec j = \partial_t \rho$ or $\vec j = \partial_t\nabla\rho$ were
incorrect. I tested them on heat dissipation, i.e. the heat kernel
$(4\pi k t)^{-1/2}\exp(-\frac{x^2}{4kt})$ and that's how I knew that I
didn't have the right concept.

Frustrated, I searched online for answers and encountered the
relationship between charge and density: the continuity equation! In
fact, this equation exactly states the relationship between these two
quantities, and captures the intuition that current density must be
derivable from charge density.

The equation is $\partial_t \rho = -\operatorname{div}\vec{F}$. The
left hand side is the rate of change of charge, while
[divergence](https://en.wikipedia.org/wiki/Divergence) is a measure of
outgoingness of the field $\vec{F}$. For example, if charge is
lessening at $x$, and so $\partial_t\rho$ is negative, we expect the
current density to be outgoing. The current density $\vec{j}$
satisfies this equation. (it is implied by [Maxwell's
equations](https://en.wikipedia.org/wiki/Maxwell%27s_equations).)

# Some more thoughts

For me, this is one of the few interesting differential equations that
I have come across, as I have now related it to my intuition and my
mistaken naive attempts to calculate current from charge.
