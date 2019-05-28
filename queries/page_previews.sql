--All page previews since deployment

SELECT year, month, day, CONCAT(year,'-',LPAD(month,2,'0'),'-',LPAD(day,2,'0')) AS date,
  SUM(view_count) AS previews_seen
  FROM wmf.virtualpageview_hourly 
  WHERE (year = 2018 AND month >=4) OR (year = 2019)
  GROUP BY year, month, day
  ORDER BY year, month, day LIMIT 10000;