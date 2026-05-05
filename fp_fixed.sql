USE pandemic;

ALTER TABLE infectious_cases_normalized
ADD COLUMN first_day_of_year DATE,
ADD COLUMN today_date DATE,
ADD COLUMN year_difference INT;

UPDATE infectious_cases_normalized
SET 
    first_day_of_year = MAKEDATE(`year`, 1),
    today_date = CURDATE(),
    year_difference = TIMESTAMPDIFF(YEAR, MAKEDATE(`year`, 1), CURDATE())
WHERE case_id > 0
  AND `year` IS NOT NULL;