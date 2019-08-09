--Query Mobile-Heavy Previews Since 2018

SELECT year, month, day, CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  SUM(view_count) AS all,
SUM(IF (FIND_IN_SET(project,
'hi.wikipedia,bn.wikipedia,id.wikipedia,ar.wikipedia,mr.wikipedia,fa.wikipedia,sw.wikipedia,tl.wikipedia,zh.wikiquote,th.wikipedia,arz.wikipedia,ml.wikipedia,ta.wikipedia,kn.wikipedia,pt.wiktionary,az.wikipedia,gu.wikipedia,ky.wikipedia,sq.wikipedia,ms.wikipedia'
) > 0, view_count, 0)) AS mh_views
  FROM wmf.virtualpageview_hourly 
  WHERE (year = 2018 AND month >=4) OR (year = 2019)
  GROUP BY year, month, day;



