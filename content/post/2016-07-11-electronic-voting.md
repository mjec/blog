+++
title = "Australia should not adopt electronic voting"
description = "There's been some talk recently about electronic voting in Australia. Here are my thoughts on why we shouldn't move away from the paper voting system."
tags = ["technical", "voting", "policy"]
date = "2016-07-11"
hasMath = false
+++

There has been a bunch of discussion about electronic voting recently, from [the bipartisan political support](http://www.abc.net.au/news/2016-07-10/election-2016-turnbull-shorten-back-electronic-voting/7584594) to [Dan Nolan's nuanced take](http://phetdreams.tumblr.com/post/146936223765/why-e-voting-is-bad-and-people-supporting-it-are). As someone with [an interest in election technology](https://easycount.mjec.net/), I have a few thoughts.

I don't actually want to get too deep into the technology side of this discussion. There are lots of great critiques of electronic voting technologies. There are also some great technologies: end-to-end systems which provide verification of each individual vote; blockchain systems which provide cryptographic evidence that results are not modified anywhere along the chain.

I think there are some broader issues though which I'd like to talk about. Before I do, one clarification: the electronic voting model that is proposed involves electronic voting machines at polling booths. We are not talking about internet voting (though that is already possible to a limited extent in some state elections, including [over unsecured email in Tasmania](http://www.tec.tas.gov.au/StateElection/Ways%20to%20Vote.html)).

## Some good things about electronic voting
An electronic count is always faster than a hand count. In the case of the Australian Senate election, we're talking about a six to eight week reduction in counting time. For the House of Representatives, it's probably a reduction of about a week (though down-to-the-wire counts will still have to wait for postal votes).

A computerized polling station would possibly also result in a lower informal vote (though research indicates this is actually unlikely). The user interface can be designed so as to prevent informal votes from being registered, or notifying the user before committing the vote. This would possibly lead to an increase in [donkey votes](https://en.wikipedia.org/wiki/Donkey_vote) and a decrease in [fun drawings of apes](http://www.dailymail.co.uk/news/article-3672061/From-ordering-kebab-voting-Harambe-gorilla-strangest-things-Australians-did-ballot-papers-election-day.html).

You could also use established user interface design techniques to improve how informed voters are. You could have candidate statements accessible in the polling booth. You could have photos. You could make it easier to rearrange preferences before committing your vote, rather than asking for a new ballot paper.

Preferences would also be unambiguous: the difference between a 1 and a 7 is clearer in bits than in hand-drawn pencil. This means no transcription or scanning errors (though it also assumes that voter intention is accurately recorded, as I explain below).

## Some bad things about electronic voting

In general, I don't mind trusting electoral commissions, but I vastly prefer to do so only on a [trust-and-verify](https://en.wikipedia.org/wiki/Trust,_but_verify) basis. I don't want any single organization to be able to determine the result by a hidden process.

**Every** electronic voting system involves some level of indirection between the way the elector expresses their voting intention and how that vote is counted. To put it another way, with paper the people counting the votes can see exactly what the elector saw, and what marks the elector made. With an electronic system, the information we get from the count has already been somewhat processed. We don't get to see exactly what button was pushed, only what data was recorded.

This distinction between raw and processed information is small but significant. It means nobody can go back to the original votes weeks later to inspect them, and [we know how important that can be](http://www.aec.gov.au/About_AEC/Publications/Reports_On_Federal_Electoral_Events/2013/keelty-report.htm). Instead of inspecting the ballot itself, you can only inspect the record of the ballot the computer has kept.

Let's for a moment though pretend that we can trust the electoral commission to keep the record perfectly. There are still a couple of problems.

Firstly we have to trust that the record is made properly. We can never go back and review the interaction between the person and the machine. It may be that [the ballot is confusing](http://www.nytimes.com/2000/11/09/us/2000-elections-palm-beach-ballot-florida-democrats-say-ballot-s-design-hurt-gore.html?pagewanted=all). It may be that the machine has been subject to [tampering](https://citp.princeton.edu/research/voting/), either before or after installation.

There are end-to-end verifiable vote systems, but these rely on individuals actually verifying their own vote. Much like verifying a cryptographic key fingerprint, we know that this is something approximately nobody will do.

The incentive to attack voting machines will be strong, too. One modified machine can influence far more votes than one modified ballot. Any attack on an electronic voting or counting system could swing thousands of votes, just by tweaking a lines of code. To have the same effect with paper ballots would require far more people to be involved, and more physical disruption.

The other thing that a slow count gives us is party scrutineers. I know that their main job is to get count information to the parties early, but as a side-effect of that they can detect and prevent fraud. There's no point sending scrutineers to every polling place if you're just observing the press of a button.

## Is the trade-off worth it?

The big benefit to electronic voting - the one people harp on about - would be knowing a week earlier which [refugee torture policy](http://www.nytimes.com/2016/05/24/opinion/australias-offshore-cruelty.html) will be implemented this year. Of course, you only get that provided postal votes aren't important; and of course [postal votes are important](http://www.abc.net.au/news/2016-07-06/election-2016-postal-votes-being-counted-in-wa-seat-of-cowan/7575252).

I think that a move to electronic voting would cause a vast reduction in some of the key checks on the validity of our electoral system, in particular the presence of scrutineers and the availability of original ballot material for review. It doesn't matter which system you choose - it can be Diebold's or punchscan or some magical open source blockchain - this is a direct consequence.

To me, that's not an acceptable compromise.
