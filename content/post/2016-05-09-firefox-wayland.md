+++
title = "Firefox for Wayland"
tags = ["technical", "wayland"]
description = "I was thinking of switching to Wayland, which means recompiling Firefox."
date = "2016-05-09"
draft = true
+++

I am an unashamed [Arch Linux](https://archlinux.org/) user. I use [i3](https://i3wm.org) as my window manager, so I thought it wouldn't be much trouble to switch to [sway](https://github.com/SirCmpwn/sway) and then I could be a Real Cool Kid(tm) using Wayland.

It turns out that switching to sway was super easy. The default touchpad click configuration is a little different (two finger tap is right click, three finger tap is middle click; whereas for X a two finger tap is middle click) but I was happy with that. For terminal emulation I've used rxvt-unicode (a.k.a. urxvt) for a while, but that isn't Wayland-native, so I switched to [Germinal](https://github.com/Keruspe/Germinal). I actually prefer that to urxvt. It's lighter weight and easier to configure, with saner default keybindings. Its role as a tmux wrapper is also nice. The only thing that is different is the loss of [ISO 14755 input](https://en.wikipedia.org/wiki/ISO_14755) but that's not really a loss.

In fact, the only trouble I had with Wayland was that Firefox, Chrome and everything else loads through XWayland. This added layer of indirection caused a CPU usage spike, which had a corresponding impact on laptop battery life. Nothing for it then but to try compiling at least one web browser for Wayland.

Conveniently GTK+3 has a Wayland backend. Just set `GDK_BACKEND=wayland` and compile. It's a simple as that. Excpt of course it isn't.

Step one, as ever, was to try the [AUR](https://aur.archlinux.org/) package `firefox-wayland`. Hasn't been touched in a while and I'm getting the "toolchain does not support C++0x/C++11 mode" error. Hmmm, that's not good. I'll just [use the source](https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Simple_Firefox_build) and try to make it work. After all, it might be that the CPU spike is caused by Wayland itself, not the XWayland indirection. And if that's the case, I'll want to be able to switch back easily.

And rather than using the official source, there's a helpful [Mozilla trunk with Wayland patches](https://github.com/stransky/gecko-dev) already around on Github.

Except of course it's not quite so simple. Arch recently upgraded to GCC version 6 (because I like living on the bleeding edge) and of course [Firefox doesn't compile with GCC 6](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70872) with `error: 'free' was not declared in this scope`. Because why would it.

Off to AUR again, and gcc53 acquired. Then we just add `ac_add_options --with-compiler-wrapper=/usr/bin/gcc53` to `mozconfig` and try `./mach build` again.

ALl these "simple" commands involve a fair amount of compiling though, sometimes ten or twenty minutes worth. This much waiting around to compile reminds me of when I used to run Gentoo. It also serves as a nice handwarmer though.
