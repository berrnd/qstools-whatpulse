SELECT
	aah.day,
	aah.hour,
	CASE WHEN IFNULL(a.name, '') = '' THEN 'UNKNOWN' ELSE a.name END AS app,
	CASE WHEN IFNULL(aah.path, '') = '' THEN 'UNKNOWN' ELSE aah.path END AS path,
	IFNULL(aah.seconds_active, 0) AS seconds_active
FROM application_active_hour aah
LEFT JOIN applications a
	ON aah.path = a.path
WHERE aah.day >= 'SYNCSTART'
