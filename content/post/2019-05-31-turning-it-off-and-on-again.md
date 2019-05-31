+++
title = "Turning it off and on again"
tags = ["technical"]
description = "Why turning a computer off and on again is a helpful thing to do."
date = "2019-05-31"
draft = true
+++

In a recent discussion with my wife, the question arose: why does
[turning a computer off and on again](https://www.youtube.com/watch?v=p85xwZ_OLX0)
help with technical problems? Being a computer person, I  was able to come
up with an answer; but not without thinking about it for a minute. This is a
more complete version of my answer, written in a way that should hopefully be
accessible to an interested layperson. I've also included plenty of references
if you [would like to know more](https://www.youtube.com/watch?v=kdrjzE1SE58&t=21).

The answer I present here may sound different to other ways people answer this
question. The underlying facts are the same, but the way of explaining it is
possibly different.

## What is a computer anyway?

Let's start with describing what a computer is and does. You may have heard that
everything in a computer is a bunch of ones and zeros. This is true[^binary] but
incomplete.

For our purposes, let's think of an ideal computer which consists of just two
components: RAM (or memory) and a CPU (or a chip).[^ideal] The memory is where
all the ones and zeros live, and the chip is hard-wired to behave in a certain
way.[^hard-wired]

In our idealized computer, there is no way to get data in or out, no way to
interact with a user, and no way to interact with another computer. All of those
are distractions for right now.

### Memory

Let's talk about memory for a second. The computer's memory is a collection of
slots, each of which can contain a one or a zero.[^memory-slots] There is some
fixed number of these slots, so we can label them: the first slot, the second,
the third and so on. Conventionally these are numbered, with the first slot
being number 0, the second slot being number 1, and so on.

We talk about the _state_ of the memory at a given point in time as being the
values associated with every slot. For example, if you have memory with four
slots[^memory-size], numbered 0-3, one valid state would be:

| Slot | Value |
| ---- | ----- |
| 0 | 0 |
| 1 | 0 |
| 2 | 0 |
| 3 | 0 |

and another would be:

| Slot | Value |
| ---- | ----- |
| 0 | 1 |
| 1 | 0 |
| 2 | 1 |
| 3 | 0 |

To make things easier, we could write that first state as `0000` and the second
as `1010`.

### The chip
Our chip operates one step at a time; these steps are often called "ticks"
(like a clock ticks once a second).[^tick] At each tick the chip can read the
entire state of the memory, and then write back the entire state of the memory.
How it makes that decision is based on how it has been wired up.

### Putting it together

This is a fair model of how a computer works.[^fsm] Importantly, 

All of those ones and zeros are the software and data of the
computer.[^software] T

[^binary]: Well, true enough. There is no concept of a 1 or 0 in the electrical circuitry inside a computer, just voltages and thresholds; when voltage exceeds the threshold it's a 1 and when it doesn't it's a 0. This itself is a simplification; feel free to read up on [transistors](https://en.wikipedia.org/wiki/Transistor) if you're intersted in the gory details.

[^ideal]: Thinking of computers in this way has a long and storied history. When academics working in computer science want talk about an idealized computer they will often use the [Turing machine](https://en.wikipedia.org/wiki/Turing_machine). The model used here is different, and does not fully describe everything that coputers can do. However those limitations aren't relevant to this post, so I've ignored them.

[^hard-wired]: Again, near enough, though not quite accurate. Are you sensing a theme? Modern computer chips aren't hard-wired, but instead have [microcode](https://en.wikipedia.org/wiki/Microcode) and [firmware](https://en.wikipedia.org/wiki/Firmware) that controls their behavior and can be changed after the chip is made.

[^tick]:  A modern chip will tick many billions of times a second, and will actually be composed of several chips (roughly speaking, cores) working together.

[^memory-slots]: This is actually... pretty accurate.

[^memory-size]: A computer with 32GB of RAM, which is not unusual these days, would have 274,877,906,944 such slots.

[^fsm]: Specifically this models a computer as a finite state machine, so called because it has a finite number of states and a way of transitioning between states.

[^software]: Again this is a simplification. 