Unique Devices on all Wikipedia projects
================

``` r
library(tidyverse)
library(ggplot2)
```

``` r
query <- "
SELECT
  year, month, CONCAT(year,'-',LPAD(month,2,'0')) AS date,
  SUM(uniques_estimate) as unique_devices
FROM 
\twmf.unique_devices_per_project_family_monthly
WHERE year >= 2018
  AND project_family = 'wikipedia'
GROUP BY year, month ORDER BY year, month LIMIT 1000;
"
results <- collect(sql(query))
save(page_previews, file = "Data/unique_devices.tsv")
```

``` r
unique_devices_monthly <- read.delim("data/unique_devices.tsv", sep = "\t", 
    stringsAsFactors = FALSE)
```

Calculate total monthly unique devices with yoy changes

``` r
unique_devices_summary <- unique_devices_monthly %>% select(-c(1, 2)) %>% arrange(date) %>% 
    mutate(unique_devices = unique_devices, YoY = unique_devices/lag(unique_devices, 
        12) - 1)

knitr::kable(unique_devices_summary)
```

| date    |  unique\_devices|        YoY|
|:--------|----------------:|----------:|
| 2018-01 |       1554911548|         NA|
| 2018-02 |       1487086660|         NA|
| 2018-03 |       1577671296|         NA|
| 2018-04 |       1522050732|         NA|
| 2018-05 |       1562607664|         NA|
| 2018-06 |       1481623542|         NA|
| 2018-07 |       1484414539|         NA|
| 2018-08 |       1516850100|         NA|
| 2018-09 |       1609517085|         NA|
| 2018-10 |       1646304870|         NA|
| 2018-11 |       1584755682|         NA|
| 2018-12 |       1589472863|         NA|
| 2019-01 |       1584392317|  0.0189598|
| 2019-02 |       1531982663|  0.0301906|
| 2019-03 |       1636520495|  0.0373013|
| 2019-04 |       1581509035|  0.0390646|
| 2019-05 |       1594894475|  0.0206621|

Plot unique devices

``` r
p <- ggplot(unique_devices_summary, aes(x = date, y = unique_devices)) + geom_col(fill = "blue") + 
    scale_y_continuous("unique devices per month", labels = polloi::compress) + 
    labs(title = "Monthly Unique Devices on All Wikipedias, 2018-2019") + ggthemes::theme_tufte(base_size = 12, 
    base_family = "Gill Sans") + theme(axis.text.x = element_text(angle = 45, 
    hjust = 1), plot.title = element_text(hjust = 0.5), panel.grid = element_line("gray70"))

ggsave(filename = "unqiue_devices_monthly.png", plot = p, path = "figures", 
    units = "in", dpi = 150, height = 6, width = 10, limitsize = FALSE)
p
```

![](figures/md_figs/unnamed-chunk-5-1.png)
