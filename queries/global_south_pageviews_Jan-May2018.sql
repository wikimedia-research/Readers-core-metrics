--Query Global South and North Countries pageviews 
--with IE7PKIRAF Correction for January 1-May 19, 2018 dates.  https://phabricator.wikimedia.org/T157404#3194046

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