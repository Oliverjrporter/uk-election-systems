library(dplyr)
library(tidyr)
library(readr)
# 1 get_parties finds the parties that ran in that years election
non_party = c("Electorate", "Valid votes", "Invalid votes", "Majority",
              "All other candidates", "Of which other winner")

get_parties = function(data)
{
  data %>%
    select(where(is.numeric), -any_of(non_party)) %>%
    names()
}

# 2 load_election reads that years election's results file, drops unused columns and checks it
load_election = function(year, dir = "data")
{
  path = file.path(dir, paste0("HoC-GE", year, "-results-by-constituency.csv"))
  data = read_csv(path, show_col_types = FALSE) %>%
    select(-any_of(c("County name", "Declaration time")))
  parties = get_parties(data)
  
  # The 2015 file has no "Of which other winner" column, so rebuild it:
  # where the winner is outside the named parties, their votes are the
  # runner-up's votes plus the majority. Everywhere else it is 0.
  if (!"Of which other winner" %in% names(data))
  {
    runner_up = apply(data[, parties], 1, max)
    data = data %>%
      mutate(`Of which other winner` = if_else(`First party` %in% parties, 0,
                                               runner_up + Majority))
  }
  
  # Checks: one row per constituency, and party votes add up to valid votes
  # (which also confirms get_parties() picked the right columns)
  stopifnot(nrow(data) == 650, !anyDuplicated(data$`ONS ID`),
            rowSums(data[, c(parties, "All other candidates")]) == data$`Valid votes`)
  
  data
}

# 3 dhondt function

dhondt = function(votes, seats, threshold = 0, total = sum(votes))
{
  eligible = data.frame(party = names(votes), votes = votes) %>%
    filter(votes / total >= threshold)
  # Build the table of quotients: each party's votes divided by 1, 2, ..., seats
  quotients = NULL
  for (k in 1:seats)
  {
    quotients = rbind(quotients,
                      mutate(eligible, divisor = k, quotient = votes / k))
  }
  # The largest quotients win seats (ties go to the party with more votes)
  winners = quotients %>%
    arrange(desc(quotient), desc(votes)) %>%
    slice(1:seats)
  # Count seats per party, giving 0 to parties that won none
  data.frame(party = names(votes)) %>%
    left_join(count(winners, party, name = "seats"), by = "party") %>%
    mutate(seats = replace_na(seats, 0L))
}

# 4 fptp the party with the most votes wins each constituency.
fptp = function(data, parties)
{
  candidates = c(parties, "Of which other winner")
  winner = candidates[apply(data[, candidates], 1, which.max)]
  
  official = if_else(data$`First party` %in% parties,
                     data$`First party`, "Of which other winner")
  if (any(winner != official))
    stop("FPTP winner differs from the official result in ",
         sum(winner != official), " constituencies")
  
  tibble(party = winner) %>%
    count(party, name = "seats") %>%
    mutate(party = recode(party, "Of which other winner" = "Other"))
}

# 5 netherlands_style one national list, threshold of one seat's worth of votes.
netherlands_style = function(data, parties, seats = nrow(data))
{
  national_votes = colSums(data[, parties])
  dhondt(national_votes, seats = seats, threshold = 1 / seats,
         total = sum(data$`Valid votes`))
}

# 6 croatia_style D'Hondt within each region, each region gets as many seats as it has constituencies.
croatia_style = function(data, parties, threshold = 0.05)
{
  data %>%
    group_split(`Region name`) %>%
    lapply(function(region_data)
      dhondt(colSums(region_data[, parties]),
             seats = nrow(region_data), threshold = threshold,
             total = sum(region_data$`Valid votes`))) %>%
    bind_rows() %>%
    group_by(party) %>%
    summarise(seats = sum(seats), .groups = "drop")
}

# 7 compare_systems 
compare_systems = function(data, parties = get_parties(data))
{
  total_seats = nrow(data)
  votes = c(colSums(data[, parties]), Other = sum(data$`All other candidates`))
  
  bind_rows(FPTP = fptp(data, parties),
            `Netherlands-style` = netherlands_style(data, parties),
            `Croatia-style` = croatia_style(data, parties),
            .id = "system") %>%
    mutate(system = factor(system, levels = c("FPTP", "Netherlands-style",
                                              "Croatia-style"))) %>%
    complete(party = names(votes), system, fill = list(seats = 0L)) %>%
    mutate(vote_share = 100 * unname(votes[party]) / sum(data$`Valid votes`),
           seat_share = 100 * seats / total_seats,
           diff = seat_share - vote_share)
}
# 8 gallagher
gallagher = function(comparison)
{
  comparison %>%
    group_by(across(any_of(c("year", "system")))) %>%
    summarise(gallagher = sqrt(sum(diff^2) / 2),
              largest_party = party[which.max(seats)],
              largest_seats = max(seats),
              majority = max(seats) > sum(seats) / 2,
              parties_with_seats = sum(seats > 0),
              .groups = "drop")
}