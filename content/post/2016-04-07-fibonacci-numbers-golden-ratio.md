+++
title = "Fibonacci numbers and the golden ratio"
description = "In which I solve exercise 1.13 of Structure and Interpretation of Computer Programs"
tags = ["technical", "rc", "math", "sicp"]
date = "2016-04-07"
hasMath = true
+++

[<abbr title="Structure and Interpretation of Computer Programs">SICP</abbr>](https://mitpress.mit.edu/sicp/full-text/book/book.html) is one of the standard books people study at <abbr title="the Recurse Center">RC</abbr>. It's definitely pretty cool, and something I've had a bit of experience with since getting half way through the [1986 lectures based on the book](http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-001-structure-and-interpretation-of-computer-programs-spring-2005/video-lectures/).

We have a study group for SICP that I have been involved with. Today one of the problems we looked at was 1.13, which is as follows:

> Prove that $Fib(n)$ is the closest integer to $\frac{\phi^n}{\sqrt{5}}$, where $\phi = \frac{1 + \sqrt{5}}{2}$.
>
> *Hint:* Let $\psi = \frac{1 - \sqrt{5}}{2}$. Use induction and the definition of the Fibonacci numbers to prove that $Fib(n) = \frac{\phi^n - \psi^n}{\sqrt{5}}$.

I happened to be the whiteboard person for this problem, and I thought the solution was a neat bit of induction. We are working (perhaps obviously) exclusively in the non-negative integers here.

We begin with some basic definitions:

$$
Fib(n) = \begin{cases}
  0 & \text{if }n = 0 \\\\\\\\
  1 & \text{if }n = 1 \\\\\\\\
  Fib(n - 1) + Fib(n - 2) & \text{otherwise}
\end{cases}
\\\\\\\\
\phi = \frac{1 + \sqrt{5}}{2}
\\\\\\\\
\psi = \frac{1 - \sqrt{5}}{2}
$$

Next, as suggested, we attempt to prove that

$$\begin{equation}f(n) = Fib(n)\end{equation}$$

given:

$$
f(n) = \frac{\phi^n - \psi^n}{\sqrt{5}}
$$

Fairly obviously:

$$
f(0) = \frac{\phi^0 - \psi^0}{\sqrt{5}} = \frac{1 - 1}{\sqrt{5}} = 0
$$

and

$$
f(1) = \frac{\phi^1 - \psi^1}{\sqrt{5}} = \frac{\frac{1 + \sqrt{5}}{2} - \frac{1 - \sqrt{5}}{2}}{\sqrt{5}} = \frac{1 + \sqrt{5} - 1 + \sqrt{5}}{2\sqrt{5}} = 1
$$

Now, the recursive step.

$$
Fib(n + 1) = Fib(n) + Fib(n - 1)
$$

Assume that $(1)$ is true, and we can replace this with:

$$
\begin{align\*}
Fib(n + 1) & =  Fib(n) + Fib(n - 1) \\\\\\\\
& =  f(n) + f(n-1) \\\\\\\\
& =  \frac{\phi^n - \psi^n}{\sqrt{5}} + \frac{\phi^{n-1} - \psi^{n-1}}{\sqrt{5}} \\\\\\\\
& =  \frac{1}{\sqrt{5}} \lgroup\phi^{n-1}(\phi + 1) - \psi^{n-1}(\psi + 1)\rgroup \\\\\\\\
& =  \frac{1}{\sqrt{5}} \lgroup\phi^{n-1}\phi^2 - \psi^{n-1}\psi^2\rgroup \\\\\\\\
& =  \frac{1}{\sqrt{5}} \lgroup\phi^{n+1} - \psi^{n+1}\rgroup \\\\\\\\
& =  f(n + 1)
\end{align\*}
$$

We therefore have:

$$
Fib(n + 1) = f(n + 1)\text{ given }Fib(n) = f(n)\text{,} \\\\\\\\
Fib(0) = f(0)\text{ and } \\\\\\\\
Fib(1) = f(1)
$$

meaning that for all non-negative integers n:

$$
Fib(n) = f(n) = \frac{\phi^n - \psi^n}{\sqrt{5}}
$$

The only perhaps non-intuitive step so far is to say that: `$\phi + 1 = \phi^2$`
and `$\psi + 1 = \psi^2$`.

This can be easily demonstrated:

$$
\begin{align\*}
\phi^2 & =  \lgroup\frac{1 + \sqrt{5}}{2}\rgroup{}^2 \\\\\\\\
 & =  \frac{1 + 2\sqrt(5) + 5}{4} \\\\\\\\
 & =  \frac{6 + 2\sqrt(5)}{4} \\\\\\\\
 & =  \frac{3 + \sqrt(5)}{2} \\\\\\\\
 & =  \frac{1 + \sqrt(5)}{2} + 1
\end{align\*}
$$

and similarly for $\psi^2$.

This is not quite the end of the problem though. We still need to show that $Fib(n)$ is the closest integer to $\frac{\phi^n}{\sqrt{5}}$.

$$
\begin{align\*}
Fib(n) - \frac{\phi^n}{\sqrt{5}} & = \frac{\phi^n - \psi^n}{\sqrt{5}} - \frac{\phi^n}{\sqrt{5}} \\\\\\\\
& = \frac{\phi^n - \psi^n - \phi^n}{\sqrt{5}} \\\\\\\\
& = \frac{\psi^n}{\sqrt{5}} \\\\\\\\
& = \frac{\lgroup\frac{1-\sqrt{5}}{2}\rgroup{}^n}{\sqrt{5}} \\\\\\\\
& = \frac{\lgroup{}1-\sqrt{5}\rgroup{}^n}{2^n\sqrt{5}} \\\\\\\\
& \approx \frac{-1.236^n}{2^n\sqrt{5}}
\end{align\*}
$$

For $n=1$ this is approximately $0.276 < 0.5$, and for $n=0$ this is approximately $0.447$. It is clear that $2^n$ grows faster than $(1 - \sqrt(5))^n$ and so the upper bound of $\lvert{}Fib(n) - \frac{\phi^n}{\sqrt{5}}\rvert{}$ is $0.447$.

As such, we can say that $\lvert{}Fib(n) - \frac{\phi^n}{\sqrt{5}}\rvert{} < 0.5$ for all non-negative integers $n$. $\Box$
