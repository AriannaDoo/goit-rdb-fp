USE pandemic;

SELECT 
    case_id,
    `year`,
    MAKEDATE(`year`, 1) AS first_day_of_year,
    CURDATE() AS today_date,
    calculate_year_difference(`year`) AS year_difference
FROM infectious_cases_normalized
WHERE `year` IS NOT NULL
LIMIT 20;