SELECT
	COUNT(request_hash) AS pv,
	impressionable_id AS project_id
FROM
	impressions
WHERE
	created_at >= DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '1 month') - INTERVAL '9 hours' AND
	created_at < DATE_TRUNC('month', CURRENT_TIMESTAMP) - INTERVAL '9 hours' AND
	impressionable_type = 'Opportunity'
GROUP BY
	impressionable_id;
