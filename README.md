# What if the UK used a different voting system?

At the 2024 general election Labour won 63% of the seats (411 of 650) on 33.7% 
of the vote. Counting the same votes under a proportional list system, no party
would have had a majority: Labour would have won 229 seats under a national list 
and 236 under a regional list.

![Seats by system](analysis_files/figure-gfm/seat-share-chart.png)

## What this project does
It recounts the constituency results of the 2015, 2017, 2019 and 2024 UK general
elections under three seat allocation rules:

- First past the post: the system the UK actually uses. The candidate with the
                       most votes wins each constituency.
                       
- National list:       all 650 seats are shared out across the UK in one count 
                       using the D'Hondt method, as in the Netherlands. A party 
                       needs one seat's worth of votes (about 0.15%) to qualify.
                       
- Regional list:       each of the 12 UK nations and regions fills as many seats 
                       as it has constituencies, using D'Hondt with a 5% threshold, similar to the system used in Croatia.

The gap between vote shares and seat shares is measured with the Gallagher index,
where 0 means seats match votes exactly. This is a mechanical recount. Voters 
and parties would behave differently under another system, so the results show 
what the same votes produce under each rule, not what would have happened in a 
real election held under it.

## Key findings

- FPTP gave a single-party majority in 3 of the 4 elections. The two list 
  systems gave one in none of the 8 cases.
  
- The Gallagher index under FPTP ranged from 6.5 to 23.7, against at most 3.6 
  under either list system.
  
- The two list systems gave similar results, differing by at most 17 seats 
  for any party in 2024.

## Data checks

- Every results file is checked on loading: 650 constituencies, no duplicates, 
  and party votes adding up to valid votes in every seat.
  
- The FPTP count is checked against the official winner in every constituency 
  and stops if any differ.
  
- The 2015 file has no column for winners outside the named parties, so it is 
  rebuilt from the runner-up's votes plus the majority.

## Full report
See [analysis.md](analysis.md).

## Data

- General election results by constituency, 2015, 2017, 2019 and 2024, House of 
  Commons Library, downloaded . 09/10/26 Open Parliament Licence.
  
- Westminster Parliamentary Constituencies (July 2024) boundaries, Office for 
  National Statistics Open Geography Portal, downloaded 09/10/26. Source: 
  Office for National Statistics licensed under the Open Government Licence v3.0.
  Contains OS data © Crown copyright and database right [year].

## Tools

R (tidyverse, sf, patchwork). AI assistance was used for [e.g. reviewing code 
and suggesting improvements to structure and charts; all analysis and code are my own].

