Readers Diversity Metrics
================

``` r
library(tidyverse)
library(ggplot2)
library(lubridate)
library(scales)
library(reshape2)
```

Interactions by Economic Region
===============================

Global South pageviews
----------------------

``` r
# Get pageviews by GS / GN / unknown for post May 2018 data. Other timespans
# need different corrections IE correction:
# https://phabricator.wikimedia.org/T157404#3194046,
# https://phabricator.wikimedia.org/T193578#4300284

query <- "
SELECT date,
countries.economic_region AS region,
SUM(pageviews_country) AS pageviews
FROM (
  SELECT year, month, day, 
  CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  country_code,
  SUM(view_count) AS pageviews_country
  FROM wmf.pageview_hourly
  WHERE ((year = 2018 AND month >= 5) OR year >= 2019)
  AND agent_type='user'
  AND NOT (country_code IN ('PK', 'IR', 'AF') -- https://phabricator.wikimedia.org/T157404#3194046
  AND user_agent_map['browser_family'] = 'IE') -- https://phabricator.wikimedia.org/T193578#4300284
  GROUP BY year, month, day, country_code) AS bydatecountry
JOIN canonical_data.countries AS countries
ON bydatecountry.country_code = countries.iso_code
GROUP BY date, countries.economic_region
ORDER BY date, region LIMIT 10000;
"
results <- collect(sql(query))
save(results, file = "Data/global_south_pageviews.tsv")
```

``` r
# Get pageviews by GS / GN / unknown with IE7PKIRAF Correction for January
# 1-May 19, 2018 dates.  https://phabricator.wikimedia.org/T157404#3194046
query <- "
SELECT date,
countries.economic_region AS region,
SUM(pageviews_country) AS pageviews
FROM (
  SELECT year, month, day, 
  CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  country_code,
  SUM(view_count) AS pageviews_country
  FROM wmf.pageview_hourly
  WHERE year = 2018 AND ((month < 5) OR (month = 5 AND day <=19))
  AND agent_type='user'
  AND NOT (country_code IN ('PK', 'IR', 'AF')
  AND user_agent_map['browser_family'] = 'IE' AND user_agent_map['browser_major'] = 7)
  GROUP BY year, month, day, country_code) AS bydatecountry
JOIN canonical_data.countries AS countries
ON bydatecountry.country_code = countries.iso_code
GROUP BY date, countries.economic_region
ORDER BY date, region LIMIT 10000;
"
results <- collect(sql(query))
save(results, file = "Data/global_south_pageview_Jan-May2018.tsv")

# Add/Reconcile global_south_pageview_Jan-May2018.tsv to
# global_south_pageviews.tsv TODO: Streamline and add code to automate query
# and data combining process Collect data with necessary corrections for
# 2015-2017 for historical analysis
```

``` r
pageviews_gs_gn <- read.delim("data/global_south_pageviews.tsv", sep = "\t", 
    stringsAsFactors = FALSE)
pageviews_gs_gn$date <- as.Date(pageviews_gs_gn$date, format = "%Y-%m-%d")
```

Calculate monthly and YoY pageviews for the global south region

``` r
gs_pageviews_monthly <- pageviews_gs_gn %>%
  mutate(date = floor_date(date, "month")) %>%
  filter(date <= '2019-04-01',
         region == 'Global South') %>% #filter out May due to incomplete data. Look only at Global South
  group_by(date) %>%
  summarise(monthly_views = sum(as.numeric(pageviews))/1E9) %>%
  arrange(date) %>%
  mutate(yearOverYear= monthly_views/lag(monthly_views,12) -1)  %>%
  mutate(type = "pageviews")

tail(gs_pageviews_monthly)
```

    ## # A tibble: 6 x 4
    ##         date monthly_views yearOverYear      type
    ##       <date>         <dbl>        <dbl>     <chr>
    ## 1 2018-11-01      3.946793           NA pageviews
    ## 2 2018-12-01      3.669640           NA pageviews
    ## 3 2019-01-01      3.864439   0.07067068 pageviews
    ## 4 2019-02-01      3.578826   0.06100653 pageviews
    ## 5 2019-03-01      3.950836   0.06569222 pageviews
    ## 6 2019-04-01      3.721101   0.03199245 pageviews

Global South seen previews
--------------------------

``` r
# Get seen previews by GS / GN / unknown
query <- "
SELECT date,
countries.economic_region AS region,
SUM(previews_seen_country) AS previews_seen
FROM (
  SELECT year, month, day, 
  CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  country_code,
  SUM(view_count) AS previews_seen_country
  FROM wmf.virtualpageview_hourly 
  WHERE (year = 2018 AND month >=4) OR (year = 2019)
  GROUP BY year, month, day, country_code) AS bydatecountry
JOIN canonical_data.countries AS countries
ON bydatecountry.country_code = countries.iso_code
GROUP BY date, countries.economic_region
ORDER BY date, region LIMIT 10000
"
results <- collect(sql(query))
save(results, file = "Data/global_south_previews.tsv")
```

``` r
previews_gs_gn <- read.delim("data/global_south_previews.tsv", sep = "\t", stringsAsFactors = FALSE)
previews_gs_gn$date <- as.Date(previews_gs_gn$date, format = "%Y-%m-%d")
```

Calculate monthly and YoY previews on desktop Wikipedia for the global south region

``` r
gs_previews_monthly <- previews_gs_gn %>%
  mutate(date = floor_date(date, "month")) %>%
  filter(date <= '2019-04-01',
         region == 'Global South') %>% #filter out May due to incomplete data. Look only at Global South
  group_by(date) %>%
  summarise(monthly_views = sum(as.numeric(previews_seen))/1E9) %>%
  arrange(date) %>%
  mutate(yearOverYear= monthly_views/lag(monthly_views,12) -1)  %>%
  mutate(type = "previews")

tail(gs_previews_monthly)
```

    ## # A tibble: 6 x 4
    ##         date monthly_views yearOverYear     type
    ##       <date>         <dbl>        <dbl>    <chr>
    ## 1 2018-11-01     0.3949143           NA previews
    ## 2 2018-12-01     0.3555215           NA previews
    ## 3 2019-01-01     0.3894631           NA previews
    ## 4 2019-02-01     0.3574372           NA previews
    ## 5 2019-03-01     0.3904542           NA previews
    ## 6 2019-04-01     0.3708813    0.2262196 previews

Monthly Interactions in Global South (Pageviews + Seen Previews)
----------------------------------------------------------------

Create chart of interactions brokend down by pageviews and previews

``` r
gs_interactions <- rbind(gs_pageviews_monthly, gs_previews_monthly)

# Stacked bar chart to compare

p <- ggplot(gs_interactions, aes(x = date, y = monthly_views, fill = forcats::fct_rev(type))) + 
    geom_col() + scale_y_continuous("seen previews (shown for at least 1 sec)\nand pageviews (in billions)", 
    breaks = c(seq(0, 20, by = 2.5))) + scale_x_date("Date", labels = date_format("%Y-%m"), 
    date_breaks = "3 months") + geom_vline(xintercept = as.numeric(as.Date("2018-04-01")), 
    linetype = "dashed", color = "blue") + geom_text(aes(x = as.Date("2018-04-01"), 
    y = 2.5, label = "Page Previews Deployment Completed"), size = 4, vjust = -1.2, 
    angle = 90, color = "black") + labs(title = "Global south pageviews and seen previews per calendar month") + 
    ggthemes::theme_tufte(base_size = 14, base_family = "Gill Sans") + theme(axis.text.x = element_text(angle = 45, 
    hjust = 1), panel.grid = element_line("gray70"), legend.position = "bottom", 
    legend.title = element_blank(), legend.text = element_text(size = 14))

ggsave(filename = "Global South pageviews and interactions_StackedBar.png", 
    plot = p, path = "figures", units = "in", dpi = 192, height = 6, width = 10, 
    limitsize = FALSE)
p
```

![](figures/README_figsunnamed-chunk-9-1.png)

Calculate monthly interactions (sum of pageviews and previews) and YoY changes in global south

``` r
gs_interactions_total <- gs_interactions %>%
  filter(date >= "2018-04-01") %>% #filter to first month previews rolled out.
  group_by(date) %>%
  summarise(interactions = sum(monthly_views)) %>%
  arrange(date) %>%
  mutate(yearOverYear= interactions/lag(interactions,12) -1) 

knitr::kable(gs_interactions_total)
```

| date       |  interactions|  yearOverYear|
|:-----------|-------------:|-------------:|
| 2018-04-01 |      3.908203|            NA|
| 2018-05-01 |      4.321567|            NA|
| 2018-06-01 |      3.987922|            NA|
| 2018-07-01 |      4.056723|            NA|
| 2018-08-01 |      4.135632|            NA|
| 2018-09-01 |      4.246182|            NA|
| 2018-10-01 |      4.454386|            NA|
| 2018-11-01 |      4.341708|            NA|
| 2018-12-01 |      4.025161|            NA|
| 2019-01-01 |      4.253902|            NA|
| 2019-02-01 |      3.936263|            NA|
| 2019-03-01 |      4.341291|            NA|
| 2019-04-01 |      4.091982|     0.0470239|

Mobile-Heavy Wikis Page Interactions
====================================

``` r
# Get pageviews for identified mobile heavy countires for post May 2018
# data. Other timespans need different corrections IE correction:
# https://phabricator.wikimedia.org/T157404#3194046,
# https://phabricator.wikimedia.org/T193578#4300284 Mobile heave wikis
# defined at:
# https://github.com/wikimedia-research/canonical-data/blob/master/mobile_heavy_wikis.csv

query <- "SELECT year, month, day, CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
 SUM(IF (FIND_IN_SET (project, 'ar.wikipedia, arz.wikipedia, az.wikipedia, bn.wikipedia, 
\tfa.wikipedia, gu.wikipedia, hi.wikipedia, id.wikipedia, kn.wikipedia,
\tky.wikipedia, ml.wikipedia, mr.wikipedia, ms.wikipedia, pt.wiktionary,
\tsq.wikipedia, sw.wikipedia, ta.wikipedia, th.wikipedia, tl.wikipedia, 
\tzh.wikiquote') > 0, view_count, 0)) AS mh_views
FROM wmf.pageview_hourly
WHERE ((year = 2018 AND month >=5) OR (year = 2019))
AND agent_type='user' 
AND NOT (country_code IN ('PK', 'IR', 'AF')
AND user_agent_map['browser_family'] = 'IE' AND user_agent_map['browser_major'] = 7)
GROUP BY year, month, day ORDER BY year, month, day LIMIT 1000;
"
results <- collect(sql(query))
save(results, file = "Data/mobile_heavy_pageviews.tsv")

# TODO: See if you can adjust query to use canonical_data.mobile_heavy_wikis
```

``` r
# Get pageviews for identified mobile heavy countires for January 1-May 19,
# 2018 dates. Other timespans need different corrections
# https://phabricator.wikimedia.org/T157404#3194046
query <- "
SELECT year, month, day, CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
 SUM(IF (FIND_IN_SET (project, 'ar.wikipedia, arz.wikipedia, az.wikipedia, bn.wikipedia, 
\tfa.wikipedia, gu.wikipedia, hi.wikipedia, id.wikipedia, kn.wikipedia,
\tky.wikipedia, ml.wikipedia, mr.wikipedia, ms.wikipedia, pt.wiktionary,
\tsq.wikipedia, sw.wikipedia, ta.wikipedia, th.wikipedia, tl.wikipedia, 
\tzh.wikiquote') > 0, view_count, 0)) AS mh_views
-- Filter for mobile heavy wikis https://github.com/wikimedia-research/canonical-data/blob/master/mobile_heavy_wikis.csv
FROM wmf.pageview_hourly
WHERE ((year = 2018 AND month >=5) OR (year = 2019))
AND agent_type='user' 
AND NOT (country_code IN ('PK', 'IR', 'AF') -- https://phabricator.wikimedia.org/T157404#3194046
AND user_agent_map['browser_family'] = 'IE') -- https://phabricator.wikimedia.org/T193578#4300284
GROUP BY year, month, day ORDER BY year, month, day LIMIT 1000;
"
results <- collect(sql(query))
save(results, file = "Data/mobile_heavy_pageviews_Jan-May2018.tsv")

# Add/Reconcile mobile_heavy_pageviews_Jan-May2018.tsv to
# mobile_heavy_pageviews.tsv TODO: Streamline and add code to automate query
# and data combining process Collect data with necessary corrections for
# 2015-2017 for historical analysis
```

Mobile-Heavy Pageviews
----------------------

``` r
mobile_heavy_pageviews <- read.delim("data/mobile_heavy_pageviews.tsv", sep = "\t", 
    stringsAsFactors = FALSE)
mobile_heavy_pageviews$date <- as.Date(mobile_heavy_pageviews$date, format = "%Y-%m-%d")
```

Calculate monthly pageviews and YoY changes on mobile-heavy wikis

``` r
mh_pageviews_monthly <- mobile_heavy_pageviews %>%
  mutate(date = floor_date(date, "month")) %>%
  filter(date <= '2019-04-01') %>% #filter out months with incomplete date
  select(-c(1,2,3)) %>%
  group_by(date) %>% #filter out May due to incomplete data. Look only at Global South
  summarise(monthly_views = sum(as.numeric(mh_views))/1E6) %>%
  arrange(date) %>%
  mutate(yearOverYear= monthly_views/lag(monthly_views,12) -1)  %>%
  mutate(type = "pageviews")

tail(mh_pageviews_monthly)
```

    ## # A tibble: 6 x 4
    ##         date monthly_views yearOverYear      type
    ##       <date>         <dbl>        <dbl>     <chr>
    ## 1 2018-11-01      718.4995           NA pageviews
    ## 2 2018-12-01      675.8047           NA pageviews
    ## 3 2019-01-01      709.3574    0.1357635 pageviews
    ## 4 2019-02-01      650.3603    0.1452997 pageviews
    ## 5 2019-03-01      683.6822    0.1396294 pageviews
    ## 6 2019-04-01      649.6815    0.1531657 pageviews

Mobile-Heavy Previews
---------------------

``` r
# Get seen previews by GS / GN / unknown
query <- "
SELECT year, month, day, CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  SUM(view_count) AS all,
SUM(IF (FIND_IN_SET(project,
'hi.wikipedia,bn.wikipedia,id.wikipedia,ar.wikipedia,mr.wikipedia,fa.wikipedia,sw.wikipedia,tl.wikipedia,zh.wikiquote,th.wikipedia,arz.wikipedia,ml.wikipedia,ta.wikipedia,kn.wikipedia,pt.wiktionary,az.wikipedia,gu.wikipedia,ky.wikipedia,sq.wikipedia,ms.wikipedia'
) > 0, view_count, 0)) AS mh_views
  FROM wmf.virtualpageview_hourly 
  WHERE (year = 2018 AND month >=4) OR (year = 2019)
  GROUP BY year, month, day
  ORDER BY year, month, day LIMIT 10000;

"
results <- collect(sql(query))
save(results, file = "Data/mobile_heavy_previews.tsv")
```

``` r
mobile_heavy_previews <- read.delim("data/mobile_heavy_previews.tsv", sep = "\t", 
    stringsAsFactors = FALSE)
mobile_heavy_previews$date <- as.Date(mobile_heavy_previews$date, format = "%Y-%m-%d")
```

Calculate monthly pageviews and YoY changes on mobile-heavy wikis

``` r
 mh_previews_monthly <- mobile_heavy_previews %>%
    mutate(date = floor_date(date, "month")) %>%
    filter(date <= '2019-04-01') %>% #filter out months with incomplete datea
    select(-c(1,2,3)) %>% 
    group_by(date) %>% 
    summarise(monthly_views = sum(as.numeric(mh_views))/1E6) %>%
    arrange(date) %>%
    mutate(yearOverYear= monthly_views/lag(monthly_views,12) -1)  %>%
    mutate(type = "previews")

tail(mh_previews_monthly)
```

    ## # A tibble: 6 x 4
    ##         date monthly_views yearOverYear     type
    ##       <date>         <dbl>        <dbl>    <chr>
    ## 1 2018-11-01      36.70485           NA previews
    ## 2 2018-12-01      35.59188           NA previews
    ## 3 2019-01-01      36.59673           NA previews
    ## 4 2019-02-01      33.31828           NA previews
    ## 5 2019-03-01      33.67126           NA previews
    ## 6 2019-04-01      33.23630  -0.03224193 previews

Interactions on Mobile-Heavy Wikis (Pageviews + Seen Previews)
--------------------------------------------------------------

Create chart of interactions broken down by pageviews and previews

``` r
mh_interactions <- rbind(mh_pageviews_monthly, mh_previews_monthly)
```

Create chart of page interactions on mobile heavy wikis

``` r
p <- ggplot(mh_interactions, aes(x = date, y = monthly_views, fill = forcats::fct_rev(type))) + 
    geom_col() + scale_y_continuous("seen previews (shown for at least 1 sec)\nand pageviews (in millions)") + 
    scale_x_date("Date", labels = date_format("%Y-%m"), date_breaks = "3 months") + 
    geom_vline(xintercept = as.numeric(as.Date("2018-04-01")), linetype = "dashed", 
        color = "blue") + geom_text(aes(x = as.Date("2018-04-01"), y = 400, 
    label = "Page Previews Deployment Completed"), size = 4, vjust = -1.2, angle = 90, 
    color = "black") + labs(title = "Mobile-heavy wiki pageviews and seen previews per calendar month") + 
    ggthemes::theme_tufte(base_size = 14, base_family = "Gill Sans") + theme(axis.text.x = element_text(angle = 45, 
    hjust = 1), panel.grid = element_line("gray70"), legend.position = "bottom", 
    legend.title = element_blank(), legend.text = element_text(size = 14))

ggsave(filename = "Mobile heavy wiki interactions_StackedBar.png", plot = p, 
    path = "figures", units = "in", dpi = 192, height = 6, width = 10, limitsize = FALSE)
p
```

![](figures/README_figsunnamed-chunk-19-1.png)

Calculate monthly interactions (sum of pageviews and previews) on desktop

``` r
  mh_interactions_total <- mh_interactions %>%
    filter(date >= '2018-04-01') %>%#page previews rolled out in April 2018
    group_by(date) %>%
    summarise(interactions = sum(monthly_views)) %>%
    arrange(date) %>%
    mutate(yearOverYear= interactions/lag(interactions,12) -1) 

knitr::kable(mh_interactions_total)
```

| date       |  interactions|  yearOverYear|
|:-----------|-------------:|-------------:|
| 2018-04-01 |      597.7332|            NA|
| 2018-05-01 |      611.8249|            NA|
| 2018-06-01 |      578.1298|            NA|
| 2018-07-01 |      620.7704|            NA|
| 2018-08-01 |      664.6630|            NA|
| 2018-09-01 |      664.9102|            NA|
| 2018-10-01 |      731.8101|            NA|
| 2018-11-01 |      755.2044|            NA|
| 2018-12-01 |      711.3966|            NA|
| 2019-01-01 |      745.9541|            NA|
| 2019-02-01 |      683.6786|            NA|
| 2019-03-01 |      717.3534|            NA|
| 2019-04-01 |      682.9178|     0.1425128|
