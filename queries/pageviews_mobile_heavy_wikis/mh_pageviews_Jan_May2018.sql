--Query Mobile-Heavy Pageviews January 1-May 19, 2018 dates
--with IE7PKIRAF Correction for this timespean.  https://phabricator.wikimedia.org/T157404#3194046

INSERT INTO TABLE mneisler.mh_pageviews_corrected
PARTITION (year, month, day)


SELECT CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
SUM(view_count) AS all_views,
SUM(IF (FIND_IN_SET(project,
'hi.wikipedia,bn.wikipedia,id.wikipedia,ar.wikipedia,mr.wikipedia,fa.wikipedia,sw.wikipedia,tl.wikipedia,zh.wikiquote,th.wikipedia,arz.wikipedia,ml.wikipedia,ta.wikipedia,kn.wikipedia,pt.wiktionary,az.wikipedia,gu.wikipedia,ky.wikipedia,sq.wikipedia,ms.wikipedia'
) > 0, view_count, 0)) AS mh_views,
year, month, day
FROM wmf.pageview_hourly
 WHERE year = 2018 AND ((month < 5) OR (month = 5 AND day <=19))
AND agent_type='user'
  AND NOT (country_code IN ('PK', 'IR', 'AF')
  AND user_agent_map['browser_family'] = 'IE' AND user_agent_map['browser_major'] = 7)
GROUP BY year, month, day 

