WITH aggregated_data AS (
    SELECT
        location,
        parameter,
        date_trunc('day', datetime) AS day,
        AVG(value) AS avg_value,
        MAX(value) AS max_value,
        MIN(value) AS min_value
    FROM
        myspectrum_schema.air_quality_data
    WHERE
        datetime BETWEEN NOW() - INTERVAL '1 year' AND NOW()
    GROUP BY
        location, parameter, date_trunc('day', datetime)
),
location_ranking AS (
    SELECT
        location,
        parameter,
        AVG(avg_value) AS yearly_avg,
        RANK() OVER (PARTITION BY parameter ORDER BY AVG(avg_value) DESC) AS rank
    FROM
        aggregated_data
    GROUP BY
        location, parameter
)
SELECT
    lr.location,
    lr.parameter,
    lr.yearly_avg,
    lr.rank,
    ad.day,
    ad.avg_value,
    ad.max_value,
    ad.min_value
FROM
    location_ranking lr
JOIN
    aggregated_data ad
ON
    lr.location = ad.location AND lr.parameter = ad.parameter
WHERE
    lr.rank <= 10
ORDER BY
    lr.parameter,
    lr.rank,
    ad.day;
