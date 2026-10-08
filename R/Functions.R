library(dplyr)
library(tidyr)

# 1. The D'Hondt function
# votes: named vector of votes, seats: number to share out,
# threshold: minimum vote share needed to win seats
dhondt = function(votes, seats, threshold = 0, total)
  {
  eligible = data.frame(party = names(votes), votes = votes) %>%
    filter(votes / total >= threshold)
  quotients = NULL
  for (k in 1:seats)
    {
    quotients = rbind(quotients,
                      mutate(eligible, divisor = k, quotient = votes / k))
    }
  winners = quotients %>%
    arrange(desc(quotient), desc(votes)) %>%
    slice(1:seats)
  seat_tab = data.frame(party = names(votes)) %>%
    left_join(count(winners, party, name = "seats"), by = "party") %>%
    mutate(seats = replace_na(seats, 0))
  
  seat_tab
  }

# 2. First past the post: the party with the most votes wins each constituency.
fptp = function(data, parties)
  {
  seat_tab = data %>%
    mutate(party = parties[apply(across(all_of(parties)), 1, which.max)]) %>%
    group_by(party) %>%
    summarise(seats = n(), .groups = "drop") %>%
    arrange(desc(seats))
  seat_tab
  }

# 3. Netherlands-style: one national list, threshold of one seat's worth of votes.
netherlands_style = function(data, parties, seats = nrow(data))
  {
  national_votes = colSums(data[, parties], na.rm = TRUE)
  dhondt(national_votes, seats = seats, threshold = 1 / seats, total = sum(data[["Valid votes"]]))
  }

# 4. Croatia-style: D'Hondt within each region, with a 5% threshold.
# Each region gets as many seats as it has constituencies.
croatia_style = function(data, parties, region_col = "Region name",
                         threshold = 0.05)
  {
  region_seats = NULL
  for (r in unique(data[[region_col]]))
    {
    region_data = data[data[[region_col]] == r, ]
    regional_votes = colSums(region_data[, parties], na.rm = TRUE)
    region_seats = rbind(region_seats,
                         dhondt(regional_votes, seats = nrow(region_data),
                                threshold = threshold, total = sum(region_data[["Valid votes"]])))
    }
  seat_tab = region_seats %>%
    group_by(party) %>%
    summarise(seats = sum(seats), .groups = "drop") %>%
    arrange(desc(seats))
  seat_tab
  }