SELECT
	day,
	CAST(x AS VARCHAR) x,
	CAST(y AS VARCHAR) y
FROM mousepoints
WHERE day >= 'SYNCSTART'
