#Pageviews by access method with corrections IE7PKIRAF: January 1-May 19, 2018

INSERT INTO TABLE mneisler.pageviews_corrected
PARTITION (year, month, day)
SELECT CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
SUM(IF(access_method = 'mobile app', view_count, null)) AS apps,
SUM(IF(access_method = 'desktop', view_count, null)) AS desktop,
SUM(IF(access_method = 'mobile web', view_count, null)) AS mobileweb,
SUM(view_count) as total,
year, month, day
FROM wmf.pageview_hourly
WHERE year = 2018 AND ((month < 5) OR (month = 5 AND day <=19))
AND agent_type='user'
AND NOT (country_code IN ('PK', 'IR', 'AF') -- https://phabricator.wikimedia.org/T157404#3194046
AND user_agent_map['browser_family'] = 'IE' AND user_agent_map['browser_major'] = 7)
GROUP BY year, month, day;
