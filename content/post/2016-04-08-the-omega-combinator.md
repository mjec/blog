+++
title = "The Omega Combinator"
tags = ["technical", "rc", "math"]
draft = true
description = "It turns out lambda calculus is pretty cool, and gives a good explanation for the Gödel incompleteness theorems."
date = "2016-04-08"
hasMath = true
+++

Yesterday we had a computer science study group session. One of the things that was spoken about was [lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus).

The underlying principle of lambda calculus is that we can apply anonymous functions to bound variables to determine a result. This is a formal logical system, which can be used to express, as it turns out [pretty much anything](https://en.wikipedia.org/wiki/Church%E2%80%93Turing_thesis).

The simplest example of a lambda function is known as the $I$ combinator a.k.a. the identity function. We express this as $I = \lambda{}x.x$, which is to say that for the bound variable $x$, replace every occurance in the things after the $.$ with $x$.

In lambda calculus, everything is a function and every function takes exactly one argument. This makes it very simple to reason about things.

So, going back to the identity, we can say that $I = \lambda{}x.x$ and therefore $\forall a: Ia = a$ (because we substitute in our argument wherever we see $x$ after the $.$).

It turns out that there are only two "important" combinators to define:

$$
K = \lambda{}x.\lambda{}y.x\\\\\\\\
S = \lambda{}x.\lambda{}y.\lambda{}z.x z (y z)
$$

You'll note that there are multiple $\lambda$s in these. That's okay; each represents a boundvariable in a function within the primary function. This is similar to the way that we deal with multiple variables in differential calculus: you only care about the ones you're differentiating with respect to. This means that each of our functions only takes one argument, but you can pass multiple arguments through other functions. This is known as [currying](https://en.wikipedia.org/wiki/Currying]).

Okay, so the $K$ combinator just discards the second thing it gets given. That is pretty simple: $\forall a, b: K a b = a$.

The $S$ combinator is a little more complex. It applies the result of $(x z)$ to the result of $(y z)$.

Between the two of them, we can define anything. For example, consider:

$$
\begin{align\*}
J & = S K K \\\\\\\\
& = \lambda{}z.K z (K z) \\\\\\\\
& = \lambda{}z.z
\end{align\*}
$$

Which we recognise as being $I$, the identity function.

By combining these functions [in clever ways](https://en.wikipedia.org/wiki/Church_encoding) you can build up an entire number system. Pretty cool, right?

Well, there are some other combinators. One that we were introduced to was the $\Omega$ combinator, defined as follows:

$\Omega = (\lambda{}x.xx)(\lambda{}x.xx)$

This is a little complex, but let's go through it step by step, kind of informally. Let's say we are going to find $\Omega g$.

First, we take the left of the two $(\lambda{}x.xx)$s. We are going to apply that function to the argument, which is the second $(\lambda{}x.xx)$. For clarity, we can write the equivalent:

$\Omega = (\lambda{}x.xx)(\lambda{}y.yy)$

Okay, so we substitute $(\lambda{}y.yy)$ in for each of the $x$s. That gives us:

$(\lambda{}y.yy)(\lambda{}y.yy)$

or, going back to the euivalent original notation:

$(\lambda{}x.xx)(\lambda{}x.xx)$

... which is what we started with!

In this way, $\Omega$ cannot be "normalized". Before we can put our argument ("$g$") in, we have to keep applying this function to itself, infinitely. This means it is impossible to compute the value of $\Omega$. This is infinite recursion.

(If *useful* recursion is what you're looking for, try the $Y$ combinator `$Y = \lambda{}x.(\lambda{}x.g(xx))(\lambda{}x.g(xx))$`. That ends up giving a fixed point for $g$ as $Y g = g (Y g)$. Proof is left as an exercise to the reader, who is free to [visit Wikipedia](https://en.wikipedia.org/wiki/Lambda_calculus#Recursion_and_fixed_points) and find it.)

The $\Omega$ combinator is interesting to me because it is neatly analagous to [Gödel's incompleteness thorems](https://en.wikipedia.org/wiki/G%C3%B6del's_incompleteness_theorems). In fact, it turns out that the canonical proofs of these theorems use the related [Gödel numbering](https://en.wikipedia.org/wiki/G%C3%B6del_numbering)

Being the schmuck I am, I asked about this, and that led to a fascinating discussion of ways to avoid such infinite recursion. In particular, you can use [typed lambda calculus](https://en.wikipedia.org/wiki/Typed_lambda_calculus) to avoid paradoxes or undecidable statements. This is because you can limit the ability of functions to take themsleves as arguments. If you properly define the input and output types of functions, you limit the ability to create recursion.

You don't, however, remove it completely. We ended up discussing a particular construct in Haskell the $\mu$ type constructor. This ultimately is a form of recursive type class, which can be more simply explained by looking at the more concrete version: the fix function.

```Haskell
fix :: (t -> t) -> t
fix f = f (fix f)
```

This function is recursive. Trying to find `fix id` for example will just cause an infinite loop. There are trivial examples which do not cause such a loop. For example:

```Haskell
g :: Int -> Int
g _ = 0
```

There is an example of a perfectly good function that we can feed to fix. It will return one thing, 0. Haskell is lazy, so it will never evaluate `(fix f)`. That will be passed as a thunk to `g` and then be discarded.

Conversely, doing `fix \x -> 1:x` will give us an infinite list of `1`s.

We spent some time exploring `fix` and determining whether it could be used to build a non-trivial (i.e. that does not simply discard its argument) recursive function. We came to the conclusion that, *with that type signature*, building such a function is impossible.

It turns out we were wrong  (????!!!!)
