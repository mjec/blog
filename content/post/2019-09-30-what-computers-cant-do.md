+++
title = "What computers can't do (that humans can)"
tags = ["text posts about nothing", "philosophy", "artificial intelligence"]
description = "Some claim we can prove there are things humans can do that computers can never do. I think they are wrong."
date = "2019-09-30"
draft = true
+++

The other day I was listening to an old-ish episode of the magnificent
[Ipse Dixet podcast](), [TKTKTK#EpisodeTitle#TKTKTK](). In it professor
TKTK#name#TKTK disucsses his paper [TKTK](), where he describes legal problem
solving as similar to the halting problem and thus not amenable to
computerization. His assertion, therefore, is that a computer can never solve
legal problems as well as a person.

To me this argument has echos of the J R Lucas paper [TKTK](), where he
describes undecideable setences (proved to exist in every finite axiomatic
system by Gödel's incompleteness theorem) as things that humans can know as
true, but which machines can never prove to be true.

I first exmained Lucas' argument in [an essay in 2003](https://mjec.net/ee.pdf),
and my position hasn't changed much. But since this has come up again in a
different context, I thought I'd expand a little on my view.

I think both Lucas' and TKTKTK's arguments are making a category mistake. They
start with an assumption - that machines can only solve problems which are
definitively answered by algorithms or mathematical inference, respectively -
and then show there exists some problem that is intractable in that system, but
which may be solveable by other means. As long as those other means are
available to humans, here is a problem people can solve that machines cannot.
Checkmate.

Their first mistake is in asserting that here is a problem humans can solve. In
fact, no human can prove an undecideable sentence to be true or false within a
finite axiomatic system. Gödel offers an excellent proof of this fact. Similarly
no human can by algorithmic process determine whether a computer program will
halt; Turing proved as much TKTKTK years ago.

These arguments thus become "computers must only operate by mathematical
inference" (in Lucas' case) or "computers must only operate by algorithm" (in
TKTKTK's). These statements are hidden as apparently obvious assumptions, but in
fact I don't think have a strong basis.

Lucas specifically states this assumption, by indicating he's talking about
"good old fashioned artificial intelligence" (GOFAI), rather than hypothetical
thinking machines that may be composed of such then-future technology as neural
networks. Back in 2003 I bought into the distinction between GOFAI and
artificial neural networks. These days, I think it's at best a distinction
without a difference.

We know this distinction is fairly meaningless because computer architectures
have not changed in the past fifty years (at least from a theoretical
standpoint, inasmuch as we can run the same programs on modern hardware), yet
we can -- and do! -- run artificial neural networks on commodity hardware. There
was a time, perhaps, when neural networks were something seemingly different in
kind from other computer programs. In 2019, they are different only in scale.

TKTKTKTK -- does lawprof state this assumption?

I belive (without proving) that each of these assumptions could be reduced to
the other. This correspondence shouldn't be too surprising, given the context
of Turing's work on the halting problem in the first place (specifically his
work on Hilber's then-unsolved problems).

In any case, there's a more substantial error.

What these assumptions miss is that while computers must follow an algorithmic
procedure to arrive at some output, that does _not_ mean that knowledge must be
derrived only from algorithmic process. The idea that in order to know a thing
the computer must have arrived at it via such a process is an absurd limitation.
We do not say that a human cannot be intelligent, or said to know something, if
they have not reasoned to that position algorithmically or by mathematical
inference. We ought to apply the same standard to artificial intelligence.

There are of course open questions in epistimology here. What _does_ it mean to
know a thing? Can whatever definition we give apply to a computer? If it does
not directly apply, is there some analogy that we can draw such that we can
meaningfully talk about computer knowledge? These are important and interesting
questions, that neither Lucas nor TKTKTKTK attempt to answer. They make an
assumption about the answer, which I think is flatly wrong (precisely because
it is so different from the answer we give when trying to describe the human
ability to know).

My personal prefernece is to describe knowledge in terms of a continuum of
certainty, with various ways in which that knowledge is supported, including by
its relationship to other facts. I know that if I drop a pen it will fall to the
ground, because I have dropped thousands of pens, and I have dropped other
objects, and I've been told that others have similar experiences, and I have an
understanding of the theoretical components of Newtonian gravitation.

Each of those bases of knowledge carries with it more connections: this pen is
like other pens (or other objects); things other people say are trustworthy;
Newtonian physics describes the universe. Thus I construct a network of
knowledge, facts about which I have varying levels of certainty, all feeding
into each other, supporting or contradicting them. If a person tells me they
dropped a pen and it hung suspended in mid-air, I'm less likely to believe them
when they say they have an alternative theory of gravity. But when someone tells
me that Newtonian gravitational theory doesn't explain gravitational waves, I
believe them. Because of this vast and complex interconnected network of
beliefs.

It's not hard to see how this could apply to a computer. Knowledge graphs are a
very common feature of smart computer systems, as are neural networks. The
outputs of those have meanings to others and appear to be knowledge to some
observers.

There are outstanding non-epistomological challenges in calling this kind of
computer output knowledge too. As with Searle's Chinese Room, there may be some
element of qualia that is missing. Perhaps the knowledge only exists in the mind
of the human consuming it. If a deep neural network identifies a forrest but
outputs to /dev/null, has it really identified anything?

I'm not saying these questions are closed: they are not. And I'm _certainly_ not
saying that computers can replace lawyers today, or that artificial intelligence
is meaningfully similar to human intelligence. Humans are still better decision-
makers. There are still fairly elementry language understanding questions - like
ambiguous pronoun mapping - where computers are nowhere close to human
understanding. Where computers do well - like in recommendation systems - it's
not clear that computers do better than a human could do, if that human had the
time and memory capacity to process all that information. Phrased that way, it
seems certain both that a human would do better, and that _we've found something
a computer can do that a human cannot_. But what does it mean to not be able to
do that? A human can't count to a trillion, not because of a lack of capability
but because of a lack of lifespan. This doesn't make a human not intelligent.

There's one final thing that has occurred to me thinking about this, which I
think is worth mentioning. I think that human and computer intelligence are
evolving not only differently, but in fact in opposite directions. Humans
evolved from animals who began by perceiving and then gradually gained cognitive
capacity, such that now we have the capacity for metacognition. That is often
thought of as a hallmark of human intelligence, to distinguish us from animals.

Computers started with substantial cognitive abilities, and even something like
metacognition: a computer can easily inspect its processes and learn from them.
Knowledge graphs in computers include explicit and preceise information about
the weights ofpieces of knowledge, which we only vaguely understand. They are
only now beginning to evolve (or rather, be given) perceptual abilities. They
don't have nerves etc.