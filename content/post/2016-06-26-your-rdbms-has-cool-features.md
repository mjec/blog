+++
title = "Your RDBMS has cool features"
description = "There are plenty of cool features in relational database management systems (e.g. PostgreSQL, MariaDB). It turns out it actually makes sense to use them when building applications."
tags = ["technical", "postgresql", "web development", "rc"]
date = "2016-06-26"
+++

*Aside: I started writing this post back in May, and have finally had a chance to finish it! Particular thanks to [Benson](http://l0stinsp4ce.com/) who worked with me on the ultimate solution.*

## How did we get here?

There's a tendency in a lot of web development to be cautious of the data layer. We outsource persistence to the magic of PostgreSQL (or MySQL or MariaDB or SQL Server or Mongo or Redis or whatever) and just kind of ignore how it works. In fact, this has now gotten to the point where the preferred means of keeping persistent data is with an ORM, whether that's the Django ORM, SQLAlchemy, Ruby on Rails' ActiveRecord or whatever the PHP folks are using these days (I know Doctrine was a thing?)

This is really the natural progression (for me at least) from the days of [PDO](http://php.net/manual/en/book.pdo.php). There's an expectation that we should abstract out data access. With PDO and the like the intention was always that you could use different database backends. I guess this makes sense for some applications - Wordpress, for example - but for many a switch in database server seems unlikely.

In fact the data access layer paradigm comes from a very enterprisey model, where the data access layer is responsible for persistence but also for translation. Often this particular application's objects might not be precisely what is stored in the database. And the [Elephant's Footprint Clan](http://thecodelesscode.com/names/Elephant's+Footprint+Clan) is free to use the enterprisey features of the server. Stored procedures and triggers abound.

So, I've decided to see what happens when I do data processing in my database rather than my application.

## The task at hand

I built and host the current iteration of the [Tasmanian Debating Union's debating management system](https://tdu.org.au/). It is a hacky Django project, hosted on the same AWS micro instance as everything else I run, from IRC loggers to this very blog.

One of the things that the system does is determine the current [ladder](https://tdu.org.au/ladder/division/34) for a particular division. Ranking on the ladder is determined by applying the following rules:

1. For each debate, teams receive points as follows:
    * +3 points for a win;
    * +1 point for a loss;
    * +0 points for a forfeit (*or a bye, at the moment; but this may change*);
    * -1 point for a late forfeit or disqualification.
2. Teams are then ordered by their points, with the team with the highest number of points ranked higher on the ladder.
3. Where teams have an equal number of points, their ordering is determined by the average rank of their speakers across all debates, where the lower average rank is better.
4. Where teams have an equal number of points and equal average ranks and the teams have debated against each other once, the team which won that debate ranks higher on the ladder.
5. Where the above rules cannot determine the order on the ladder, behaviour is undefined.

It is worth noting that rule (4) may result in a cycle where more than two teams are on the same number of points and same ranks. For example, if A, B and C are all equal to that point, and A beat B head to head, B beat C and C beat A, then no ordering can be determined.

It is also worth noting that "undefined" behaviour is not really a good thing in any competition. There are several established means of resolving these types of conflicts, all with different pros and cons. Some such methods include:

 * rank teams by random process (e.g. coin flip);
 * adjudicators meet and choose an ordering;
 * hold one or more further debates to resolve the ambiguity;
 * the team with the higher total raw scores ranks higher;
 * the team with the highest net margins of wins ranks higher; or
 * teams are ranked based on the ranks of the teams they defeated who are not deadlocked with them.

The last three of these are of course also not guaranteed to give a clear answer.

It turns out that since initially writing this post we ended up with precisely that undefined outcome happening. The first idea we had was to resolve it by looking at the ranks of the teams the deadlocked teams defeated; but that also resulted in an undefined outcome. The rule which was added was that teams are ranked by the average points margin of their debates (with winning margins counted as positive and losing margins counted as negative). This resolved the ambiguity, at least for now.

## The old solution

For better or for worse, here is my old means of generating a ladder. You can see that it involves at least six database queries per team, meaning 96 aggregating queries to calculate the ladder for one division. This is a very expensive operation.

At the moment it's not wrapped in a transaction, but it should be.

I have some pretty aggressive caching, so I avoid running this if at all possible. But this is really a data processing task being done in the application layer. Do we do any better moving it to the database server?

```Python
def generate_ladder(debates, teams):
    ladder = {}
    for team in teams:
        ladder[team] = TeamOnLadder(team, debates)
; though that benefit is also obviously available using a queue
        # Add points for aff wins/losses/etc
        pts = (
            debates
            .filter(aff_id=team)
            .values("aff_id")
            .order_by()
            .annotate(
                points=Sum(
                    Case(
                        When(final_outcome__startswith="A", then=Value(3)),  # aff won
                        When(final_outcome="NF", then=Value(0)),             # aff forfeited
                        When(final_outcome="NL", then=Value(-1)),            # aff forfeited late
                        When(final_outcome="ND", then=Value(-1)),            # aff was disqualified
                        When(final_outcome="NW", then=Value(1)),             # aff was defeated
                        default=Value(0),                                    # ignore anything else
                        output_field=IntegerField()))
            ))
        if pts.count() > 0:
            ladder[team].add_points(
                pts[0]['points']
            )

        # Add points for neg wins/losses/etc
        pts = (
            debates
            .filter(neg_id=team)
            .values("neg_id")
            .order_by()
            .annotate(
                points=Sum(
                    Case(
                        When(final_outcome__startswith="N", then=Value(3)),  # neg won
                        When(final_outcome="AF", then=Value(0)),             # neg forfeited
                        When(final_outcome="AL", then=Value(-1)),            # neg forfeited late
                        When(final_outcome="AD", then=Value(-1)),            # neg was disqualified
                        When(final_outcome="AW", then=Value(1)),             # neg was defeated
                        default=Value(0),                                    # ignore anything else
                        output_field=IntegerField()))
            ))
        if pts.count() > 0:
            ladder[team].add_points(
                pts[0]['points']
            )

        # Add average ranks from aff appearances
        ladder[team].adjust_rank(
            Score.objects.filter(
                official=True,
                debate__aff_id=team,
                position__in=['1A', '2A', '3A']
            ).order_by().aggregate(Avg('rank'))['rank__avg'],
            Score.objects.filter(
                official=True,
                debate__aff_id=team,
                position__in=['1A', '2A', '3A']
            ).order_by().distinct('debate_id').count()
        )

        # Add average ranks from neg appearances
        ladder[team].adjust_rank(
            Score.objects.filter(
                official=True,
                debate__neg_id=team,
                position__in=['1N', '2N', '3N']
            ).order_by().aggregate(Avg('rank'))['rank__avg'],
            Score.objects.filter(
                official=True,
                debate__neg_id=team,
                position__in=['1N', '2N', '3N']
            ).order_by().distinct('debate_id').count()
        )

    ret = []
    for i in sorted(ladder, key=ladder.get, reverse=True):
        ret.append({
            'team_id': i,
            'points': ladder[i].points,
            'avg_rank': ladder[i].avg_rank,
        })

    return ret

class TeamOnLadder():
    def __init__(self, team_id, debates):
        self.team_id = team_id
        self.points = 0
        self.avg_rank = 0
        self.count = 0
        self.debates = debates

    def add_points(self, points):
        self.points += points

    def adjust_rank(self, rank, count):
        if rank is None:
            return
        self.avg_rank = \
            ((self.count * self.avg_rank) + (count * rank)) \
            / (self.count + count)
        self.count += count

    def __cmp__(self, other):
        if self.points > other.points:
            return +1
        if self.points < other.points:
            return -1

        if self.avg_rank < other.avg_rank:
            return +1
        if self.avg_rank > other.avg_rank:
            return -1

        # We select all debates in the season between this team and other.
        # We give +1 for any debate this team won, and -1 for any team the other won.
        # This will result in:
        #   None if there were no debates between them
        #   0 if they each won the same number of debates
        #  >0 if self won more debates against other than other won against self
        #  <0 if other won more debates against self than self won against other
        head_to_head = self.debates\
            .filter(
                (Q(aff_id=self.team_id) & Q(neg_id=other.team_id)) |
                (Q(aff_id=other.team_id) & Q(neg_id=self.team_id))
            ).aggregate(
                head_to_head=Sum(Case(
                    When(final_outcome__startswith="A", aff_id=self.team_id,
                         then=1),    # self won
                    When(final_outcome__startswith="N", neg_id=self.team_id,
                         then=1),    # self won
                    When(final_outcome__startswith="A", aff_id=other.team_id,
                         then=-1),  # other won
                    When(final_outcome__startswith="N", neg_id=other.team_id,
                         then=-1),  # other won
                    default=0,  # ignore unresolved
                    output_field=IntegerField()))
            )['head_to_head']

        if head_to_head is not None:
            return head_to_head

        # The teams did not compete against each other
        return 0

```

## The new idea

There are a couple of different ways to do this, but I think there are two things I would particularly like to have:

1. a (materialized?) view which has columns `team_id`, `points` and `avg_rank`; and
2. potentially an ordering function so I can do a query with `ORDER BY ladder(team_id)`.

Using a materialized view for the first part is nice because it gives us an aggressive cache, and we actually have some pretty easy triggers for refreshing it (an insert/delete of a team; a change to a debate outcome; or an insert/delete in scores). This can all be handled in PostgreSQL, so I know it will never affect the application (and will happen outside the request/response lifecycle of the web application).

The other thing that's nice about this is that it's cached in the database layer, not in the web layer. This means that a clearing the web cache (as might happen for a range of reasons) won't force us to redo 100 queries unnecessarily.

It turns out that just the materialized view will be enough. This key insight was [Benson](http://l0stinsp4ce.com/)'s: have a view with columns for points, average rank, and number of head-to-head wins. An appropriate ordering can then be had from those columns alone.

Together Benson and I spent more than an hour working through this SQL. Here I'll show you the complete `CREATE MATERIALIZED VIEW` we ended up with below. There are comments throughout.

```SQL
CREATE MATERIALIZED VIEW ladder as
(with
    match_points as (
        -- This gives us points awarded to aff and neg for each debate outcome
        -- i.e. aff_id, neg_id, aff_points, neg_points for every row in
        -- debate_debate.
        --
        -- Team Points will be awarded as follows:
        -- Win: three (3) points
        -- Defeat: one (1) point
        -- Forfeit: zero (0) points
        -- Late Forfeit (after noon on the day of the debate): minus one (-1) point
        -- Disqualification: minus 1 (-1) point
        select
            case
                WHEN final_outcome LIKE 'A%' THEN 3 -- Aff win
                WHEN final_outcome = 'NF' THEN  0   -- Aff win by neg forfeit
                WHEN final_outcome = 'NL' THEN -1   --   ... late forfeit
                WHEN final_outcome = 'ND' THEN -1   --   ... disqualification
                WHEN final_outcome = 'NW' THEN  1   --   ... withdrawal
            end as aff_points,
            case
                WHEN final_outcome LIKE 'N%' THEN 3 -- Neg win
                WHEN final_outcome = 'AF' THEN  0   -- Neg win by neg forfeit
                WHEN final_outcome = 'AL' THEN -1   --   ... late forfeit
                WHEN final_outcome = 'AD' THEN -1   --   ... disqualification
                WHEN final_outcome = 'AW' THEN  1   --   ... withdrawal
            end as neg_points,
            aff_id,
            neg_id
        from debate_debate
        ),

    team_ranks as (
        -- The average of ranks of team speakers; nice and easy
        select
            team_id, avg(rank) as avg_rank
        from
            debate_score
        where
            rank is not null -- ranks can be null for reply speeches
            AND official = true -- official scores only
        group by team_id
        ),

    ladder_figures as (
        -- This lets us select the total number of points for a particular team.
        -- We also have to give that team their average points for a bye
        -- (otherwise teams with byes end up not getting any points for that
        -- debate, which is unfair).
        select
            t.id as team_id,    -- what you'd expect
                    avg_rank,   -- because we have this above
                    sum(        -- this is their "earned" points
                        case
                         when p.aff_id = t.id then aff_points
                         when p.neg_id = t.id then neg_points
                        end
                    ) + (avg(   -- plus average points for each by
                        case
                         when p.aff_id = t.id then aff_points
                         when p.neg_id = t.id then neg_points
                        end
                    ) * count(distinct bye_debates.id)) as points
        from competition_team t
        left join team_ranks r on t.id = r.team_id
        join match_points p on t.id in (p.neg_id, p.aff_id)
        left join debate_debate bye_debates
            on bye_debates.final_outcome LIKE 'B%' and t.id in (bye_debates.aff_id, bye_debates.neg_id)
            -- Byes have a NULL aff_id or neg_id and an outcome of BA or BN
            -- so we can safely use t.id in (aff_id, neg_id) where that is the
            -- outcome.
        group by t.id, avg_rank
        -- we have to include avg_rank in group by to select it
        ),

    tied_teams as (
        -- This gives us an array of team_ids where all teams within the array
        -- are tied (by points and rank) and are in the same division.
        select array_agg(l.team_id) as ids
             from ladder_figures l
             inner join competition_team t on l.team_id = t.id
             group by (l.avg_rank, l.points, t.division_id)
             having count(distinct l.team_id) > 1
        ),

    h2h as (
        -- Head to head comparisons for tied teams. We begin by unnest()ing the
        -- team_ids array. We then count the number of wins and return that for
        -- each such id, given the team is againsta nother team that is also
        -- tied.
        select
            unnest(t.ids) as team_id,
            sum(
                (unnest(t.ids) = d.aff_id)::int * case when final_outcome like 'A%' then 1 else 0 end
              + (unnest(t.ids) = d.neg_id)::int * case when final_outcome like 'N%' then 1 else 0 end
            ) as wins
        from
            debate_debate d
        join
            tied_teams t
        on (d.aff_id = ANY(t.ids) and d.neg_id = ANY(t.ids))
        group by unnest(t.ids)
        ),

    margins as (
        -- Average margins across all debates
        -- Note that debate_score.poi can be NULL, and SUM() across a NULL
        -- value will be NULL, so we have to use COALESCE.
        -- We want margins of wins to count as +ve and margins of losses to
        -- count as -ve.         
        SELECT
            t.id AS team_id,
            AVG(CASE
                WHEN t.id = raw_margins.aff_id THEN raw_margins.aff_margin
                WHEN t.id = raw_margins.neg_id THEN raw_margins.neg_margin
                ELSE NULL END
            ) AS avg_margin
        FROM (
                -- This subquery gives us margins for each debate, both for
                -- the aff and the neg. It is probably a little inefficient to
                -- do this, because aff_margin will always be -neg_margin, but
                -- it makes the above select simpler (because we don't have
                -- to figure out who won).
                SELECT
                    d.aff_id as aff_id,
                    SUM(CASE
                        WHEN s.team_id = d.aff_id THEN s.matter + s.manner + s.method + COALESCE(s.poi, 0)
                        ELSE 0 - s.matter - s.manner - s.method - COALESCE(s.poi, 0)
                    END) AS aff_margin,
                    d.neg_id as neg_id,
                    SUM(CASE
                        WHEN s.team_id = d.neg_id THEN s.matter + s.manner + s.method + COALESCE(s.poi, 0)
                        ELSE 0 - s.matter - s.manner - s.method - COALESCE(s.poi, 0)
                    END) AS neg_margin
                FROM
                    debate_score s
                LEFT JOIN
                    debate_debate d ON s.debate_id = d.id
                WHERE
                    official = true
                GROUP BY debate_id, d.aff_id, d.neg_id
            ) AS raw_margins
        LEFT JOIN
            competition_team AS t ON t.id = raw_margins.aff_id OR t.id = raw_margins.neg_id
        GROUP BY t.id
        )

    -- FINALLY! We get to what we are actually selecting!
    select
        l.team_id,
        l.points,
        l.avg_rank,
        h.wins,
        m.avg_margin
    from
        ladder_figures l
    left join
        h2h h
    on h.team_id = l.team_id
    left join
        margins m
    on l.team_id = m.team_id
    -- We have to order by ranks *ascending*, hence multiplying by -1
    order by (l.points, (-1 * l.avg_rank), h.wins, m.avg_margin) DESC
);
```

This is, by far, the longest SQL query I've ever used. However, it works amazingly well. We go from a hundred queries to one per division. And it's quick to do so, because it's materialized. We also get to figure out ranks in the database using a window function:

```SQL
SELECT
    rank() over (order by points desc, avg_rank asc, wins desc, avg_margin desc) AS place,
    team_id,
    points,
    avg_rank,
    wins,
    avg_margin
    FROM ladder
    WHERE team_id IN (
        SELECT id FROM competition_team WHERE division_id = %s
    )
```

That's it! Nice and simple.

## Gotchas

There are a few downsides. We are now a long way from the Django ORM; any change to the structure of the database needs to be reflected in the definition of the view. Any query needs to be done with raw SQL. I become responsible for this, instead of migrations magic.

Being a materialized view, I also need to ensure it doesn't become stale. The way I did this was with triggers:

```SQL
CREATE OR REPLACE FUNCTION refresh_ladder_view() RETURNS trigger AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW ladder;
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER refresh_ladder_new_score AFTER INSERT OR UPDATE ON debate_score
    EXECUTE PROCEDURE refresh_ladder_view();

CREATE TRIGGER refresh_ladder_delete_score AFTER DELETE ON debate_score
    EXECUTE PROCEDURE refresh_ladder_view();

CREATE TRIGGER refresh_ladder_delete_debate AFTER DELETE ON debate_debate
    EXECUTE PROCEDURE refresh_ladder_view();

CREATE TRIGGER refresh_ladder_new_debate AFTER INSERT OR UPDATE ON debate_debate
    FOR EACH ROW
    WHEN (NEW.final_outcome LIKE 'A%' OR NEW.final_outcome LIKE 'N%' OR NEW.final_outcome LIKE 'B%')
    EXECUTE PROCEDURE refresh_ladder_view();

CREATE TRIGGER refresh_ladder_team_changes AFTER INSERT OR DELETE ON competition_team
    EXECUTE PROCEDURE refresh_ladder_view();
```

Nice and simple. But again, this comes at a cost. Specifically, the `REFRESH MATERIALIZED VIEW` call takes a second or two at least. And it runs on every update, delete or insert. Mostly this isn't a problem, but sometimes it is.

In particular, shortly after this I needed to modify the `debate_debate` table to insert a new column. On my local machine, this `ALTER TABLE` took 45 minutes (having locked a key table against reads!) before I gave up on it. This obviously would not do.

After a couple of hours of fruitless thought (interspersed with an episode or two of Veep) it occurred to me that the trigger might be the issue. Disable the trigger and bam, the schema change (inserting a new NULLable column) was over in less than a second, as you would expect.

Of course, this meant diving into the Django migration file and manually adding some operations: an `ALTER TABLE debate_debate DISABLE TRIGGER USER` before the table update and `ALTER TABLE debate_debate ENABLE TRIGGER USER` afterwards. And you have to make sure there's an appropriate transaction wrapping the whole thing too; or you have to manually run `REFRESH MATERIALIZED VIEW` afterwards.

Overall though, it was definitely worth the tradeoff. PostgreSQL is far better at manipulating data than I am. It is built for this. It is clever. There are a few things you have to think about, and you lose cross-backend compatibility (at least explicitly), but it works faster and cleaner. That's the name of the game.
