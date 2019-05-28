--Unique Devices on all Wikipedia projects
SELECT
  year, month, CONCAT(year,'-',LPAD(month,2,'0')) AS date,
  SUM(uniques_estimate) as unique_devices
FROM 
	wmf.unique_devices_per_project_family_monthly
WHERE year >= 2018
  AND project_family = 'wikipedia'
GROUP BY year, month ORDER BY year, month LIMIT 1000;