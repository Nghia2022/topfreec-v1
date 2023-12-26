SELECT
	COUNT(request_hash) AS pv,
	impressionable_id AS project_id
FROM
	impressions
WHERE
	created_at >= DATE_TRUNC('day', CURRENT_TIMESTAMP - INTERVAL '24 hours') - INTERVAL '9 hours' AND
	created_at < DATE_TRUNC('day', CURRENT_TIMESTAMP) - INTERVAL '9 hours' AND
	impressionable_type = 'Opportunity'
GROUP BY
	impressionable_id;
