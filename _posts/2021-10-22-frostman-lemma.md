---
layout: post
title: Frostman's lemma
---
{% include mathjax.html %}

# Frostman's lemma in metric spaces

## Definitions

Let $(X,d)$ be a metric space and $E\subseteq X$. Let $\operatorname{diam}(\cdot)$ be the diameter of a set.

The $s$-dimensional Hausdorff measure $\mathcal H^s(E)$ of $E$, $s \geq 0$ is defined by

$$
\begin{align}
\mathcal H^s(E) & := \lim_{\epsilon \to 0} \mathcal H^s_\epsilon(E), \\
\mathcal H^s_\epsilon(E) & := \inf\{ \sum_{j=1}^\infty (\operatorname{diam} U_j)^s : U_j \text{ open cover of $E$ with $\operatorname{diam}U_j < \epsilon$} \}, & 0 \leq \epsilon \leq +\infty.
\end{align}
$$

We actually have $\mathcal H^s_\epsilon(E) \nearrow \mathcal H^s(E)$ as $\epsilon\to 0$, and $\mathcal H^s$ is a measure on $X$ for every $s\geq 0$.

Moreover, we have that $\mathcal H^s(E) = +\infty$ for $s < s_0$, $\mathcal H^s(E) = 0$ for $s > s_0$ and the unique $s_0\geq 0$ for which this occurs is the Hausdorff dimension of $E$ , denoted by $\dim_\mathcal H E$. The value of $\mathcal H^s(E)$ at $s = \dim_{\mathcal H} E$ can be any value in $[0,+\infty]$.

Finally, let $P(E)$ denote all the Borel probability measures supported on $E$. 

## Introduction to Frostman's lemma

Assume that a set $E$ supports a positive Borel measure $\mu$ such that for every ball $B$ of radius $r$ we have, for some $s>0$, 

$$
\begin{align}
\label{eq:frostman1}
\mu(B) & \leq r^s.
\end{align}
$$

It follows then that for any open cover $U_j$ of $E$ we have:

$$
\begin{align}
0 < \mu(E) \leq \sum_{j=1}^\infty \mu(U_j) \leq \sum_{j=1}^\infty (\operatorname{diam}U_j)^s,
\end{align}
$$

and by taking the infimum over all such covers, we obtain $\mathcal H^s(E) > 0$.

Frostman's lemma is the converse: if $\mathcal H^s(E) > 0$, then a positive Borel measure supported on $E$ and satisfying \eqref{eq:frostman1} exists.

## Frostman's lemma on compact metrix spaces. (nonconstructive) {#compact}

Let $E$ be a compact metric space. If $\mathcal H^s(E) > 0$ then there's $\mu\in P(E)$ and $C>0$ with $\mu(B) \leq Cr^s$ for all balls $B$ of radius $r$.

### Proof

Define $p : C(E) \to \mathbb C$ by

$$
\begin{align}
p(f) & := \inf\{\sum_{j=1}^\infty c_j (\operatorname{diam}E_j)^s : \text{Numbers } c_j \geq 0 \text{ and sets } E_j \text{ such that } \sum_{j=1}^\infty c_j 1_{E_j} \geq f\}.
\end{align}
$$

The function $p$ is a nonnegative sublinear functional:

- $p(f) \leq \|f\|_\infty \operatorname{diam}E$.
- $p(f) = 0$ for $f \leq 0$.
- $p(tf) = tp(f)$ for $t\geq 0$.
- $p(f + g) \leq p(f) + p(g)$ since a bound for $f$ and a bound for $g$ adds to a bound for $f + g$.
- $$p(1_{E}) = \mathcal{H}^{s}_{\infty}(E)$$, comparing definitions. Thus $$p(1_{E}) > 0$$.

Thus by the [Hahn-Banach theorem](https://en.wikipedia.org/wiki/Hahn%E2%80%93Banach_theorem) there's some nonnegative functional $\mu$ (which is a Radon measure by the [Riesz-Markov-Kakutani representation theorem](https://en.wikipedia.org/wiki/Riesz%E2%80%93Markov%E2%80%93Kakutani_representation_theorem)) with

$$
\begin{align}
\mu(E) & = p(1_E), \\
| \int f d\mu| & \leq p(f), & \text{(thus $\mu$ nonnegative),} \\
\mu(B) &  \leq \sup_{\substack{f \in C(E) \\ f \leq 1_B}} p(f) \leq (2r)^s.
\end{align}
$$

Normalize to obtain a probability measure.

## Frostman's lemma on complete separable metric spaces.

Frostman's lemma holds in this case too.

The compactness condition in [the above section](#compact) can be removed. In our construction the sublinear functional $p$ does not take any infinite values, but it could be the case that $\mathcal H^s(X) = +\infty$ for a general metric space without any compact subsets $E\subset X$ with $\mathcal H^s(E) > 0$. However, this does not occur for the standard Hausdorff measure; there are other Hausdorff measures, constructed by functions that are different from the standard power functions $t\mapsto t^s$, which exhibit this peculiar behavior. The counter-example is constructed in Davies, Rogers [^1] and the proof that Frostman's lemma holds for analytic subsets of complete separable metric spaces is Corollary 7 in Howroyd [^2], effectively proving (among other things) that for any analytic $A\subseteq X$ there exists some compact $E\subseteq A$ with $0 < \mathcal H^s(E) < +\infty$ if $\mathcal H^s(A) > 0$.

## Frostman's lemma on Euclidean spaces. (constructive, original proof)

Let $E \subset \mathbb R^n$ compact. If $\mathcal H^s(E) > 0$ then there's $\mu\in P(E)$ and $C>0$ with $\mu(B) \leq Cr^s$ for all balls $B$ of radius $r$.

### Definitions

Let $\mathcal Q_k(E)$ denote all the dyadic half-open cubes of side length $2^{-k}$ intersecting $E$. 

### Proof

Assume $E\subset [0,1)^n$. It suffices to show that $\mu(Q) \leq r^s$ for every dyadic half-open cube $Q\subseteq [0,1)^n$, since any set of diameter at most $2r$ is containted in at most $2^n$ dyadic cubes with side length $r$. We wish to construct measures $\mu_k$ decreasing to $\mu$ such

$$
\begin{align}
\label{eq:frostman}
\mu(Q) \leq r^s
\end{align}
$$

for every dyadic half-open cube of level at most $k$.

#### Naive construction

In all our constructions, we define our measures to be multiples of the Lebesgue measure. When we define $\mu(Q) = \lambda$, it means that $\mu$ restricted on $Q$ equals $\lambda$ times the normalized Lebesgue measure (i.e. divided by the Euclidean volume of $Q$).

- **Idea:** Define $\nu_k(Q) := 2^{-ks}$ for $Q \in \mathcal Q_k(E)$.
- **Issue:** $\nu_{k}([0,1)^n) = 2^{k(n-s)}$. Thus \eqref{eq:frostman} does not hold.
- **Why does this happen?** Some parts of $E$ may be "too dense" to look $s$-dimensional at the $2^{-k}$-scale. 
- **Solution:** Look at the previous cubes in $Q\in \mathcal Q_{k-1}(E)$ and correct $\nu_k(Q)$ if necessary by making it smaller. One proceeds with a finite induction of $k$ steps correcting all the way up to $\mathcal Q_0(E)$.

#### Finite induction

We are going to construct $\nu_k, \nu_{k-1}, \dots, \nu_0$ inductively, with $\mu_k := \nu_0$.

For the base case, define $\nu_k(Q) := 2^{-ks}$ for $Q\in \mathcal Q_k(E)$ and $\nu_k := 0$ otherwise.

For the induction, if $\nu_j(Q) \leq 2^{-(j-1)s}$, define

$$
\begin{align}
\left.\nu_{j-1}\right|_Q := \left.\nu_{j}\right|_Q.
\end{align}
$$

Otherwise, if $\nu_j(Q) > 2^{-(j-1)s}$ for some $Q\in\mathcal Q_{j-1}(E)$, then redefine $\nu_{j-1}(Q) := 2^{-(j-1)s}$. (this impacts all the next-level cubes "under" $Q$; it makes their measures smaller). 


Define $\mu_k := \nu_0$ and consider its properties:

- $\mu_k([0,1)^n) \leq 1$, by the correction step.
- $\mu_k(Q) \leq r^s$ for every dyadic half-open cube of radius at least $2^{-k}$, ensured by the initial construction and correction steps.
- $\mu_k(X) \geq \mu_{k+1}(X)$ for all Borel $X\subseteq [0,1)^n$, by comparing the intermediate measures constructed for $\mu_{k}$ and $\mu_{k+1}$.

By the last property, $\mu(X) := \lim \mu_k(X)$ is well-defined and $\mu(Q) \leq r^s$ for all dyadic cubes of side length $r$. Moreover, $\mu(E) \gtrsim \mathcal H^s_\infty(E)$ since the bound holds for each $\mu_k(E)$:

$$
\begin{align}
\mu_k(E) & = \sum_{Q\text{ initial or corrected}} (\operatorname{side}Q)^s \geq 2^{-s/2}\mathcal H^s_\infty(E).
\end{align}
$$

(Note that $\mathcal H^s_\infty(E) > 0$ since $\mathcal H^s_\infty(E) > \min\{\mathcal H^s_\epsilon(E), \epsilon^s\}$ for all $\epsilon > 0$ and $\mathcal H^s_\epsilon(E) \nearrow \mathcal H^s(E) > 0$ by hypothesis)

[^1]: Davies, Roy O.; Rogers, C. A. The problem of subsets of finite positive measure. Bull. London Math. Soc. 1 (1969), 47–54.
[^2]: Howroyd, J. D. On dimension and on the existence of sets of finite positive Hausdorff measure. Proc. London Math. Soc. (3) 70 (1995), no. 3, 581–604.
