SELECT
	salesforce.opportunity.id AS project_id,
	COALESCE(pv, 0) AS pv
FROM
	salesforce.opportunity
LEFT OUTER JOIN
	(SELECT
		COUNT(request_hash) AS pv,
		impressionable_id
	FROM
		impressions
	WHERE
		created_at >= DATE_TRUNC('day', CURRENT_TIMESTAMP + INTERVAL '9 hours') - INTERVAL '1 day' - INTERVAL '9 hours' AND
		created_at < DATE_TRUNC('day', CURRENT_TIMESTAMP + INTERVAL '9 hours') - INTERVAL '9 hours' AND
		impressionable_type = 'Opportunity'
	GROUP BY
		impressionable_id
	) AS subquery
ON
	salesforce.opportunity.id = subquery.impressionable_id;
