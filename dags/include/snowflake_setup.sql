-- ==========================================
-- 1. ОБЩАЯ НАСТРОЙКА БАЗЫ
-- ==========================================
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE DATABASE AIRBYTE_DATABASE;

-- ==========================================
-- 2. НАСТРОЙКА БЕЗОПАСНОСТИ ДЛЯ AIRBYTE (Инжестинг)
-- ==========================================
USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS AIRBYTE_ROLE;
CREATE USER IF NOT EXISTS AIRBYTE_USER 
    PASSWORD = 'ОченьКрутойПароль123' 
    DEFAULT_ROLE = AIRBYTE_ROLE;
    
GRANT ROLE AIRBYTE_ROLE TO USER AIRBYTE_USER;

USE ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE AIRBYTE_ROLE;
GRANT ALL PRIVILEGES ON DATABASE AIRBYTE_DATABASE TO ROLE AIRBYTE_ROLE;
GRANT CREATE SCHEMA ON DATABASE AIRBYTE_DATABASE TO ROLE AIRBYTE_ROLE;


-- ==========================================
-- 3. НАСТРОЙКА БЕЗОПАСНОСТИ ДЛЯ AIRFLOW / DBT (Разработка)
-- ==========================================
-- Создаем роль для Airflow, чтобы он не ходил под ACCOUNTADMIN
USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS AIRFLOW_ROLE;
CREATE USER IF NOT EXISTS AIRFLOW_USER 
    PASSWORD = 'НадежныйПарольДляЭирфлоу2026' 
    DEFAULT_ROLE = AIRFLOW_ROLE;

GRANT ROLE AIRFLOW_ROLE TO USER AIRFLOW_USER;

-- Даем Airflow права на запуск склада (вычисления)
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE AIRFLOW_ROLE;

-- Даем Airflow права ЧТЕНИЯ данных, которые привез Airbyte
GRANT USAGE ON DATABASE AIRBYTE_DATABASE TO ROLE AIRFLOW_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE AIRBYTE_DATABASE TO ROLE AIRFLOW_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE AIRBYTE_DATABASE TO ROLE AIRFLOW_ROLE;

-- Даем Airflow права создавать новые таблицы/схемы (это критично для dbt моделей!)
GRANT CREATE SCHEMA ON DATABASE AIRBYTE_DATABASE TO ROLE AIRFLOW_ROLE;