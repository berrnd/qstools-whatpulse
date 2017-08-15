SELECT
	mfa.day,
	mfa.hour,
	CASE WHEN IFNULL(a.name, '') = '' THEN 'UNKNOWN' ELSE a.name END AS app,
	CASE WHEN IFNULL(mfa.path, '') = '' THEN 'UNKNOWN' ELSE mfa.path END AS path,
	CASE mfa.button
		WHEN 0 THEN 'left'
		WHEN 1 THEN 'right'
		WHEN 2 THEN 'middle'
		ELSE 'extra'
	END AS button,
	IFNULL(mfa.count, 0) AS count
FROM mouseclicks_frequency_application mfa
LEFT JOIN applications a
	ON mfa.path = a.path
WHERE mfa.day >= 'SYNCSTART'

UNION

SELECT
	mf.day,
	mf.hour,
	'UNKNOWN' AS app,
	'UNKNOWN' AS path,
	CASE mf.button
		WHEN 0 THEN 'left'
		WHEN 1 THEN 'right'
		WHEN 2 THEN 'middle'
		ELSE 'extra'
	END AS button,
	IFNULL(mf.count - (
		SELECT SUM(count)
		FROM mouseclicks_frequency_application
		WHERE day = mf.day
			AND hour = mf.hour
			AND button = mf.button
		), 0) AS count
FROM mouseclicks_frequency mf
WHERE mf.day >= 'SYNCSTART'
