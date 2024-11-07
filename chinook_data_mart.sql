USE chinook_data_mart;

CREATE TABLE dim_date (
    date_key INT NOT NULL,
    full_date DATE NULL,
    date_name CHAR(11) NOT NULL,
    date_name_us CHAR(11) NOT NULL,
    date_name_eu CHAR(11) NOT NULL,
    day_of_week TINYINT NOT NULL,
    day_name_of_week CHAR(10) NOT NULL,
    day_of_month TINYINT NOT NULL,
    day_of_year SMALLINT NOT NULL,
    weekday_weekend CHAR(10) NOT NULL,
    week_of_year TINYINT NOT NULL,
    month_name CHAR(10) NOT NULL,
    month_of_year TINYINT NOT NULL,
    is_last_day_of_month CHAR(1) NOT NULL,
    calendar_quarter TINYINT NOT NULL,
    calendar_year SMALLINT NOT NULL,
    calendar_year_month CHAR(10) NOT NULL,
    calendar_year_qtr CHAR(10) NOT NULL,
    fiscal_month_of_year TINYINT NOT NULL,
    fiscal_quarter TINYINT NOT NULL,
    fiscal_year INT NOT NULL,
    fiscal_year_month CHAR(10) NOT NULL,
    fiscal_year_qtr CHAR(10) NOT NULL,
    PRIMARY KEY (date_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

DROP PROCEDURE IF EXISTS PopulateDateDimension;

CREATE PROCEDURE PopulateDateDimension(BeginDate DATE, EndDate DATE)
BEGIN
    DECLARE DateCounter DATE;
    DECLARE LastDayOfMon CHAR(1);
    DECLARE FiscalYearMonthsOffset INT DEFAULT 6;
    DECLARE FiscalCounter DATE;

    SET DateCounter = BeginDate;

    WHILE DateCounter <= EndDate DO
        SET FiscalCounter = DATE_ADD(DateCounter, INTERVAL FiscalYearMonthsOffset MONTH);

        IF MONTH(DateCounter) = MONTH(DATE_ADD(DateCounter, INTERVAL 1 DAY)) THEN
            SET LastDayOfMon = 'Y';
        ELSE
            SET LastDayOfMon = 'N';
        END IF;

        INSERT INTO dim_date (
            date_key, full_date, date_name, date_name_us, date_name_eu, 
            day_of_week, day_name_of_week, day_of_month, day_of_year, 
            weekday_weekend, week_of_year, month_name, month_of_year, 
            is_last_day_of_month, calendar_quarter, calendar_year, 
            calendar_year_month, calendar_year_qtr, fiscal_month_of_year, 
            fiscal_quarter, fiscal_year, fiscal_year_month, fiscal_year_qtr
        ) VALUES (
            (YEAR(DateCounter) * 10000) + (MONTH(DateCounter) * 100) + DAY(DateCounter),
            DateCounter,
            DATE_FORMAT(DateCounter, '%d-%b-%Y'),
            DATE_FORMAT(DateCounter, '%m-%d-%Y'),
            DATE_FORMAT(DateCounter, '%d-%m-%Y'),
            DAYOFWEEK(DateCounter),
            DAYNAME(DateCounter),
            DAYOFMONTH(DateCounter),
            DAYOFYEAR(DateCounter),
            CASE WHEN DAYOFWEEK(DateCounter) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END,
            WEEKOFYEAR(DateCounter),
            MONTHNAME(DateCounter),
            MONTH(DateCounter),
            LastDayOfMon,
            QUARTER(DateCounter),
            YEAR(DateCounter),
            DATE_FORMAT(DateCounter, '%Y-%m'),
            CONCAT(YEAR(DateCounter), 'Q', QUARTER(DateCounter)),
            MONTH(FiscalCounter),
            QUARTER(FiscalCounter),
            YEAR(FiscalCounter),
            DATE_FORMAT(FiscalCounter, '%Y-%m'),
            CONCAT(YEAR(FiscalCounter), 'Q', QUARTER(FiscalCounter))
        );

        SET DateCounter = DATE_ADD(DateCounter, INTERVAL 1 DAY);
    END WHILE;
END //

DELIMITER ;

CALL PopulateDateDimension('2021-01-01', '2025-12-31');

