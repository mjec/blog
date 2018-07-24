+++
title = "Django's QuerySet union isn't quite what it seems"
tags = ["technical", "django", "python", "web development", "rc"]
description = "Django claims that QuerySets support a union operator. It turns out that doesn't actually give you a union of two query sets, and it can silently munge your query."
date = "2016-06-27"
hasMath = false
+++

One of the websites I maintain is for the [Tasmanian Debating Union](https://tdu.org.au/). I built a competition management system, a rewrite in Django of a system originally designed and built in PHP by my friend [Pat](http://www.publicself.com.au/).

The database schema for this system includes a table with one row per debate. Those debates have associated teams (one affirmative, one negative) and an outcome (e.g. affirmative win, negative win). There's therefore no single column to select the winning team.

As an aside, this particular database structure is something I chose, a change from Pat's system (which had aff, neg and winner IDs). This way is more normalized (it's impossible, even without constraints, for a winner to be a team which did not participate in the debate) but I'm not sure it is particularly advantageous. It does significantly increase the complexity of certain types of queries.

One such example is a query designed to fetch the IDs of winning teams in a particular round, with the intention of having those winners move on to the next round. (In the <abbr title="Tasmanian Debating Union">TDU</abbr>'s competition, this only happens in finals.)

I had originally conceived of this query in the following way:

```SQL
SELECT aff_id AS team
    FROM debate
    WHERE round_id = ? AND outcome='affwin'
UNION
SELECT neg_id AS team
    FROM debate
    WHERE round_id = ? AND outcome='negwin'
```

I then translated that into what I thought was its natural Django representation:

```Python
team_ids = (
    Debate
    .objects
    .filter(round=previous_round, outcome='affwin')
    .only('aff')
    .annotate(team=F('aff')) |
    Debate
    .objects
    .filter(round=previous_round, outcome='negwin')
    .only('neg')
    .annotate(team=F('neg'))
).order_by('debate_number').values_list('team', flat=True)
```

Note that I've used the `|` operator between those two `QuerySet`s. I understood that this generated the `UNION` between them. Not so! To my surprise, the SQL that I ended up with was of the form:

```SQL
SELECT aff_id AS team
    FROM debate
    WHERE (round_id = ? AND outcome='affwin') OR
        (round_id = ? AND outcome='negwin')
```

The `.annotate(team=F('neg'))` was totally clobbered.

This behaviour is actually not totally unreasonable - it is a significant optimization if it is what's intended. However, it wasn't what I wanted at all.

What I ended up doing was what I ought to have done the whole time, and represents a pattern I see a lot for this table structure:

```Python
team_ids = (
    Debate
    .objects
    .filter(round=previous_round)
    .annotate(
        team=Case(
            When(outcome='affwin', then=F('aff')),
            When(outcome='negwin', then=F('neg')),
        )
    )
).order_by('debate_number').values_list('team', flat=True)
```

This is actually a lot cleaner, and the SQL surely runs faster. Overall, a better outcome. But if I actually need `UNION`, it's good to know I can't really get it with the Django ORM.
