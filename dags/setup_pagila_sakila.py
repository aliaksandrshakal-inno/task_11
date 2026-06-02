from airflow.decorators import dag
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.bash import BashOperator  # Добавили этот импорт
from pendulum import datetime

@dag(
    dag_id='setup_databases_taskflow',
    schedule=None,
    max_active_runs=1,
    start_date=datetime(2024, 1, 1),
    template_searchpath=['/opt/airflow/dags'],
    catchup=False,
    tags=['setup', 'pagila', 'sakila'],
)
def setup_db_dag():
    
    # --- PAGILA TASKS ---
    pagila_schema = PostgresOperator(
        task_id='load_pagila_schema',
        postgres_conn_id='pagila_conn',
        sql='include/pagila-schema-final.sql',
    )

    # ЗАМЕНИЛИ PostgresOperator на BashOperator
    pagila_data = BashOperator(
        task_id='load_pagila_data',
        bash_command=(
            'psql "postgresql://airflow:airflow@postgres/airflow" '
            '-f /opt/airflow/dags/include/pagila-data-final.sql'
        )
    )

    # --- SAKILA TASKS ---
    sakila_schema = PostgresOperator(
        task_id='load_sakila_schema',
        postgres_conn_id='sakila_conn',
        sql='include/sakila-schema-final.sql',
    )

    # Если Сакила тоже падает с ошибкой на данных, её тоже можно заменить на BashOperator
    sakila_data = BashOperator(
    task_id='load_sakila_data',
    bash_command='psql "postgresql://airflow:airflow@postgres/airflow" -f /opt/airflow/dags/include/sakila-data-final.sql'
)

    # Зависимости
    pagila_schema >> pagila_data
    sakila_schema >> sakila_data

setup_db_dag()