+++
title = "Non-proofs"
description = "I've enjoyed reading a few spurious proofs today"
tags = ["technical", "math", "rc"]
date = "2016-04-19"
hasMath = true
+++

Today I read a [thread of fake proofs](https://www.reddit.com/r/math/comments/4fhd8b/what_are_some_interesting_andor_fun_fake_proofs/) on /r/math. The whole thread is great, but perhaps my favourite is the following "proof" I reproduce here.

We attempt to find:

$$\int \frac{1}{f} \frac{\mathrm{d}f}{\mathrm{d}x}$$

Let `$\mathrm{d}u = - \frac{1}{f^2}\mathrm{d}x$` and `$v = f$`.

Then we use the ordinary method of integration by parts:

$$\int u \mathrm{d}v = uv - \int v \mathrm{d}u$$

Substituting:

$$\int \frac{1}{f} \mathrm{d}f = \frac{1}{f}f - \int f - \frac{1}{f^2} \mathrm{d}f$$

Then simplify:

$$\int \frac{1}{f} \mathrm{d}f = 1 + \int \frac{1}{f} \mathrm{d}f$$

Then we subtract `$\int \frac{1}{f} \mathrm{d}f$` from each side and we are left incontrovertibly with:

$$0 = 1 \\ \Box$$
