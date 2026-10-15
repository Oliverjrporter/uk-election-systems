# What if the UK used a different voting system?

At the 2024 general election Labour won 63% of the seats (411 of 650) on 33.7% 
of the vote. Counting the same votes under a proportional list system, no party
would have had a majority: Labour would have won 229 seats under the Netherlands
style system and 236 under the Croatia style system.

![Seats by system](Analysis_files/figure-gfm/seat-share-chart-1.png)

## Why this question

First past the post often gives parties a very different share of seats to
their share of votes, but it usually means one party can govern alone. After
the 2024 result I wanted to see how big that gap really is, and what the same
votes would look like under a proportional system.

## Why these systems

I picked two list systems that sit at opposite ends. The Netherlands counts the
whole country as one constituency with a tiny threshold, so it's about as close
as seats can get to votes. Croatia shares seats out by region with a 5%
threshold, which is closer to how a UK version might actually work. For that I
used the 12 regions the UK used for Parliament elections. Croatia itself uses 10
districts of 14 seats, so mine is based on its approach rather than an exact copy.

## Key findings

The thing that surprised me most was how few MPs actually won a majority in
their own seat. In 2024 only 96 of the 650 got at least half the votes, and 54
won with less than a third.

![Win Share Map](Analysis_files/figure-gfm/map-win-share-1.png)

*Each constituency coloured by the winner’s share of the vote, 2024*

FPTP gave one party a majority in 3 of the 4 elections I looked at. The list
systems never did, in any of the 8 counts. The Gallagher index under FPTP went
from 6.5 up to 23.7, while neither list system got above 3.6.

I expected the two list systems to give quite different results, but they
didn't. In 2024 no party's seats differed by more than 17 between them, which
suggests switching to a list system matters a lot more than the details of
which one.

## Method

I recounted the constituency results for 2015, 2017, 2019 and 2024 three
different ways. Under FPTP the winner in each constituency takes the seat. Both
list systems use the D'Hondt method; the Netherlands style one does a single
national count, and the Croatia style one counts each of the 12 regions
separately, giving each region as many seats as it has constituencies.

To compare them I used the Gallagher index, which measures how far seat shares
are from vote shares. A score of 0 would mean they match exactly.
  
## Data checks

Every results file gets checked when it loads. There have to be 650
constituencies with no duplicates, and the party votes have to add up to the
valid votes in every seat. If a column gets picked up as a party by mistake
the totals won't match and the code stops.

The FPTP count is also checked against the official winner in each
constituency, and it stops if even one is different.

The 2015 file doesn't have a column for winners outside the named parties, so
I rebuilt it from the runner up's votes plus the majority.

## Limitations

This is a recount of the same votes, not a prediction. Under a different
system people would vote differently. Fewer would vote tactically, more parties
would stand in more places and the results could look quite different.

Votes for independents and small parties are grouped together as "other
candidates" in the data, so under the list systems they can't win any seats.
That's part of why neither list system gets a Gallagher index of 0.

The Gallagher index only measures one thing. It doesn't say anything about
keeping a local MP, how coalitions would form or how easy the ballot is to
use, and I haven't tried to weigh those up here.

## Full report
See [Analysis.md](Analysis.md).

## Data

- General election results by constituency, 2015, 2017, 2019 and 2024, House of 
  Commons Library, downloaded 9 October 2026. Open Parliament Licence.
  
- Westminster Parliamentary Constituencies (July 2024) boundaries, Office for 
  National Statistics Open Geography Portal, downloaded 9 October 2026. Source: 
  Office for National Statistics licensed under the Open Government Licence v3.0.
  Contains OS data © Crown copyright and database right 2024.

## Tools

R (tidyverse, sf, patchwork). AI (Claude) was used to review and debug the code.

