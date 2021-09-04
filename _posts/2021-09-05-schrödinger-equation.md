---
layout: post
title: A derivation of the Schrödinger equation
---
{% include mathjax.html %}

# Introduction
The [Schrödinger equation](https://en.wikipedia.org/wiki/Schr%C3%B6dinger_equation) governs the time evolution of a quantum mechanical system. The equation we wish to derive reads,

$$
\begin{align}
\label{eq:main}
i\frac d{dt} \psi(t) & = \hat H(t) \psi(t).
\end{align}
$$

To derive the Schrödinger equation, we need a hypothesis, a guiding principle. This is the [unitarity principle](https://en.wikipedia.org/wiki/Unitarity_(physics)) which says that whatever the setup, its *state* (all of the information about the system at a certain time) is some unit vector in some complex Hilbert space.

> **Example setup**
>
> Consider a box of unit dimensions which contains 5 electrons in it, with some positions and velocities given by certain distributions. What is the probability that after one second we find an electron at a given distance from the corners of the box?

The unitarity principle guarantees that there exists some complex Hilbert space $\mathcal H$ such that at every moment in time $t\geq 0$, we have some unit vector $\psi(t) \in \mathcal H$ that somehow encodes everything there is to know about the system of this example.

# Derivation of the equation
We now will talk about the derivation. Since $\psi(t)$ is a unit vector at all times there must exist a unitary operator $U(t)$ such that

$$
\begin{align}
\label{eq:unitary}
\psi(t) & = U(t)\psi_0,
\end{align}
$$

where $\psi_0 = \psi(0)$ is the state of the system at the beginning of the experiment. The group of unitary operators is an infinite dimensional Lie group with Lie algebra that of skew-Hermitian operators. A skew-Hermitian operator $T$ satisfies $T^* = -T$, and so $A = iT$ is Hermitian. Using the exponential map, we have

$$
\begin{align}
\label{eq:exp}
U(t) & = \exp(-iA(t)),
\end{align}
$$

for some Hermitian operator $A(t)$. Using \eqref{eq:exp} in \eqref{eq:unitary} and differentiating in time gives

$$
\begin{align}
\psi'(t) & = -iA'(t)\exp(-iA(t))\psi_0.
\end{align}
$$

If we define $H(t) := A'(t)$, which is again a Hermitian operator (since the Lie algebra is a vector space and thus closed under derivatives unlike curved spaces), we get \eqref{eq:main}.

# Conclusion

The conclusion is that the Schrödinger equation is nothing but the equation for the dynamics of a point in a sphere. Instead of moving the point around, we rotate the sphere around, and thus study the dynamics of the group of rotations; using the exponential map we are led to the exponential equation (essentially $f' = cf$),  and the correspondence of skew-Hermitian with Hermitian simply introduces the imaginary factor.
