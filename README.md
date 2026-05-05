## Фінальний проєкт

### Тема Реляційні бази даних. Нормалізація даних, аналіз показників захворюваності та використання SQL-функцій.

---

## Опис проєкту

У фінальному проєкті було виконано роботу з реальним набором даних про інфекційні захворювання.

Під час виконання проєкту було:

- створено схему `pandemic`;
- імпортовано дані з CSV-файлу за допомогою Table Data Import Wizard;
- переглянуто структуру та вміст таблиці `infectious_cases`;
- виконано нормалізацію таблиці до третьої нормальної форми;
- створено дві нормалізовані таблиці;
- виконано аналітичний SQL-запит для атрибута `Number_rabies`;
- побудовано колонку різниці в роках за допомогою вбудованих SQL-функцій;
- створено та використано власну SQL-функцію для розрахунку різниці в роках.

---

# Завдання 1. Завантаження даних

Було створено схему `pandemic` та обрано її як схему за замовчуванням.

```sql
DROP DATABASE IF EXISTS pandemic;
CREATE DATABASE pandemic;
USE pandemic;
```

<img width="1900" height="1025" alt="p1_create_schema_pandemic png" src="https://github.com/user-attachments/assets/8591ad65-68bf-4bd7-a44e-7f9a243be262" />


Після цього дані були імпортовані з CSV-файлу в таблицю `infectious_cases` за допомогою Table Data Import Wizard.

Для перегляду імпортованих даних було виконано запит:

```sql
SELECT *
FROM infectious_cases
LIMIT 10;
```
<img width="1870" height="1029" alt="p1_imported_data_preview png" src="https://github.com/user-attachments/assets/2880c730-bbdb-4eff-bdf3-06ec9ce78f1b" />

Для перевірки кількості завантажених рядків було виконано запит:

```sql
SELECT COUNT(*) AS total_rows
FROM infectious_cases;
```

<img width="1898" height="1031" alt="p1_count_infectious_cases png" src="https://github.com/user-attachments/assets/12c73cf9-33f1-469b-8a90-f247b3ccba94" />



Результат:

```text
total_rows = 7271
```

Також було переглянуто структуру таблиці:

```sql
DESCRIBE infectious_cases;
```

<img width="1898" height="1026" alt="p1_describe_infectious_cases png" src="https://github.com/user-attachments/assets/9897be5a-bf8e-41be-a481-669e353cf981" />

---

# Завдання 2. Нормалізація таблиці infectious_cases до 3НФ

У початковій таблиці `infectious_cases` атрибути `Entity` та `Code` повторювалися в багатьох рядках.

Для усунення дублювання було створено окрему таблицю `entities`, яка містить унікальні комбінації `Entity` та `Code`.

<img width="1843" height="1025" alt="p2_create_enteties png" src="https://github.com/user-attachments/assets/72d93190-3a10-4c03-a760-095f9f154976" />

Також було створено таблицю `infectious_cases_normalized`, у якій замість повторюваних `Entity` та `Code` використовується зовнішній ключ `entity_id`.

Таким чином було створено дві нормалізовані таблиці:

- `entities`
- `infectious_cases_normalized`

```sql
USE pandemic;

DROP TABLE IF EXISTS infectious_cases_normalized;
DROP TABLE IF EXISTS entities;

CREATE TABLE entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    UNIQUE KEY unique_entity_code (entity, code)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT 
    Entity,
    COALESCE(Code, '')
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    year INT,
    number_yaws TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    number_rabies TEXT,
    number_malaria TEXT,
    number_hiv TEXT,
    number_tuberculosis TEXT,
    number_smallpox TEXT,
    number_cholera_cases TEXT,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);

INSERT INTO infectious_cases_normalized (
    entity_id,
    year,
    number_yaws,
    polio_cases,
    cases_guinea_worm,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases
)
SELECT 
    e.entity_id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e 
    ON ic.Entity = e.entity
    AND COALESCE(ic.Code, '') = e.code;
```


<img width="1843" height="1026" alt="p2_entities_table png" src="https://github.com/user-attachments/assets/184afd52-c95e-4802-acf0-7f2ab97439fc" />


Для перевірки кількості рядків у нормалізованій таблиці було виконано запит:

```sql
SELECT COUNT(*) AS normalized_rows
FROM infectious_cases_normalized;
```


<img width="1835" height="1020" alt="p2_count_normalized_table png" src="https://github.com/user-attachments/assets/246b4a1e-2171-4340-a264-3e5624155604" />


Кількість рядків у нормалізованій таблиці має відповідати кількості рядків в оригінальній таблиці.


---

# Завдання 3. Аналіз даних для Number_rabies

Для кожної унікальної комбінації `Entity` та `Code` було пораховано:

- середнє значення `Number_rabies`;
- мінімальне значення `Number_rabies`;
- максимальне значення `Number_rabies`;
- суму значень `Number_rabies`.

Порожні значення були відфільтровані перед виконанням розрахунків.

Результат було відсортовано за середнім значенням у порядку спадання та обмежено 10 рядками.

```sql
USE pandemic;

SELECT 
    e.entity,
    e.code,
    AVG(CAST(icn.number_rabies AS DECIMAL(20, 2))) AS avg_rabies,
    MIN(CAST(icn.number_rabies AS DECIMAL(20, 2))) AS min_rabies,
    MAX(CAST(icn.number_rabies AS DECIMAL(20, 2))) AS max_rabies,
    SUM(CAST(icn.number_rabies AS DECIMAL(20, 2))) AS sum_rabies
FROM infectious_cases_normalized icn
JOIN entities e 
    ON icn.entity_id = e.entity_id
WHERE icn.number_rabies IS NOT NULL
  AND icn.number_rabies != ''
GROUP BY e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;
```

<img width="1842" height="1025" alt="p3_rabies_analysis png" src="https://github.com/user-attachments/assets/9fdeb8b4-4a7c-4d87-833e-28c83432567a" />


---

# Завдання 4. Побудова колонки різниці в роках

ALTER TABLE and UPDATE

```sql
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

SELECT 
    case_id,
    `year`,
    first_day_of_year,
    today_date,
    year_difference
FROM infectious_cases_normalized
LIMIT 20;
```

<img width="1892" height="1030" alt="p4_alter_update_year_difference png" src="https://github.com/user-attachments/assets/ee688d0c-f87b-49b2-9b00-a9c6a771f890" />


---

# Завдання 5. Побудова власної функції

Було створено власну функцію `calculate_year_difference`.

Функція приймає значення року, створює дату першого січня відповідного року та повертає різницю в роках між цією датою і поточною датою.

```sql
DROP FUNCTION IF EXISTS calculate_year_difference;

DELIMITER //

CREATE FUNCTION calculate_year_difference(input_year INT)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
END //

DELIMITER ;

```

Після створення функцію було використано на даних з таблиці `infectious_cases_normalized`.

```sql
SELECT 
    case_id,
    `year`,
    calculate_year_difference(`year`) AS calculated_year_difference
FROM infectious_cases_normalized
WHERE `year` IS NOT NULL
LIMIT 20;
```

<img width="1872" height="1022" alt="p5_custom_function_year_difference png" src="https://github.com/user-attachments/assets/cb67a01d-c540-4726-b622-2536ad0c6852" />

---

# Висновок

У фінальному проєкті було створено схему `pandemic`, імпортовано дані, виконано нормалізацію таблиці `infectious_cases` до 3НФ, проведено аналіз атрибута `Number_rabies`, побудовано колонку різниці в роках за допомогою вбудованих SQL-функцій та створено власну функцію для розрахунку різниці в роках.
