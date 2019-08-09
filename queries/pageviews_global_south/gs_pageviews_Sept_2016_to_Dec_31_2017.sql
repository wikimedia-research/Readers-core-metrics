#Query Global South and North Countries pageviews 
#Pageviews by access method with corrections IE7PKIRAF & iOS mainpage: ...-Dec 31, 2017

INSERT INTO TABLE mneisler.gs_pageviews_corrected
PARTITION (year, month, day)

SELECT date,
countries.economic_region AS region,
SUM(pageviews_country) AS pageviews,
year, month, day
FROM (
  SELECT 
  CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  country_code,
  SUM(view_count) AS pageviews_country,
  year, month, day						
FROM wmf.pageview_hourly					
WHERE (year = 2017 OR (year = 2016 AND month >=9))					
AND agent_type='user'					
AND NOT ( -- See https://phabricator.wikimedia.org/T154735					
access_method = 'mobile app' AND user_agent_map['os_family'] = 'iOS' AND					
(					
-- includes the 10 most viewed projects on the iOS app (Jan 2017):					
(   project = 'en.wikipedia' AND					
page_title = 'Main_Page'  )					
OR					
(   project = 'de.wikipedia'					
AND page_title = 'Wikipedia:Hauptseite'  )					
OR  -- for some strange reason a lot of 5.3.x clients access the redirect instead:					
(   project = 'de.wikipedia'					
AND page_title = 'Hauptseite'  )					
OR					
(   project = 'fr.wikipedia'					
AND page_title = 'Wikipédia:Accueil_principal'  )					
OR					
(   project = 'ja.wikipedia' AND					
page_title = 'メインページ'   )					
OR					
(   project = 'nl.wikipedia'					
AND page_title = 'Hoofdpagina'  )					
OR					
(   project = 'es.wikipedia' AND					
page_title = 'Wikipedia:Portada'  )					
OR					
(   project = 'it.wikipedia'					
AND page_title = 'Pagina_principale'  )					
OR					
(   project = 'ru.wikipedia' AND					
page_title = 'Заглавная_страница'  )					
OR					
(   project = 'zh.wikipedia'					
AND page_title = 'Wikipedia:首页'  )					
OR					
(   project = 'sv.wikipedia' AND					
page_title = 'Portal:Huvudsida'  )					
OR					
(   project = 'fi.wikipedia' AND					
page_title = 'Wikipedia:Etusivu'  )					
OR					
(   project = 'pl.wikipedia' AND					
page_title = 'Wikipedia:Strona_główna'  )					
)					
)					
AND NOT (country_code IN ('PK', 'IR', 'AF') -- https://phabricator.wikimedia.org/T157404#3194046					
AND user_agent_map['browser_family'] = 'IE' AND user_agent_map['browser_major'] = 7)					
GROUP BY year, month, day, country_code) AS bydatecountry
JOIN canonical_data.countries AS countries
ON bydatecountry.country_code = countries.iso_code
GROUP BY date, year, month, day, countries.economic_region
