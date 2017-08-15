SELECT
	ab.day,
	CASE WHEN IFNULL(a.name, '') = '' THEN 'UNKNOWN' ELSE a.name END AS app,
	CASE WHEN IFNULL(ab.path, '') = '' THEN 'UNKNOWN' ELSE ab.path END AS path,
	ab.upload,
	ab.download
FROM application_bandwidth ab
LEFT JOIN applications a
	ON ab.path = a.path
WHERE ab.day >= 'SYNCSTART'

UNION

SELECT
	nib.day,
	'UNKNOWN' AS app,
	'UNKNOWN' AS path,
	IFNULL(SUM(nib.upload) - (
		SELECT SUM(upload)
		FROM application_bandwidth
		WHERE day = nib.day
		), 0) AS upload,
	IFNULL(SUM(nib.download) - (
		SELECT SUM(download)
		FROM application_bandwidth
		WHERE day = nib.day
		), 0) AS download
FROM network_interface_bandwidth nib
WHERE nib.day >= 'SYNCSTART'
GROUP BY nib.day
