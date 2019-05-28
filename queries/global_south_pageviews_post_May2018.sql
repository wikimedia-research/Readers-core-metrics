--Query Global South and North Countries pageviews post May 2018. 
-- add IE correction: https://phabricator.wikimedia.org/T157404#3194046, https://phabricator.wikimedia.org/T193578#4300284

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