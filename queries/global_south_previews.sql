--Query Global South and North Countries seen previews on deskop

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
