from airflow.decorators import dag
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator  
from airflow.hooks.base import BaseHook              
from pendulum import datetime
import urllib.request
import json
import base64  # Добавили для авторизации

def trigger_airbyte_via_connection():
    # 1. Извлекаем хост, порт, логин и пароль из админки Airflow Connections
    conn = BaseHook.get_connection('airbyte_conn')
    url = f"http://{conn.host}:{conn.port}/api/v1/connections/sync"
    
    # Если в админке Airflow логин/пароль пустые, ставим дефолтные для локального Airbyte
    username = conn.login if conn.login else "airbyte"
    password = conn.password if conn.password else "password"
    
    # 2. Кодируем логин и пароль в стандартный формат Basic Auth
    auth_bytes = f"{username}:{password}".encode('utf-8')
    auth_base64 = base64.b64encode(auth_bytes).decode('utf-8')
    
    # Твой личный проверенный ID связи из Airbyte
    connection_id = "412b0be7-a1f7-4827-90b9-60b634f615f9" 
    
    # 3. Шлем POST-запрос с заголовком авторизации
    payload = json.dumps({"connectionId": connection_id}).encode('utf-8')
    req = urllib.request.Request(
        url, 
        data=payload, 
        headers={
            'Content-Type': 'application/json',
            'Authorization': f'Basic {auth_base64}'  # Передаем пароль серверу
        }, 
        method='POST'
    )
    
    print(f"Airflow авторизуется и шлет запрос на: {url}")
    with urllib.request.urlopen(req) as response:
        result = response.read().decode()
        print(f"Ответ от Airbyte: {result}")

@dag(
    dag_id='setup_databases_taskflow',
    schedule=None,
    max_active_runs=1,
    start_date=datetime(2024, 1, 1),
    template_searchpath=['/opt/airflow/dags'],
    catchup=False,
    tags=['setup', 'pagila', 'sakila', 'airbyte', 'verified'],
)
def setup_db_dag():
    
    # --- PAGILA TASKS ---
    pagila_schema = PostgresOperator(
        task_id='load_pagila_schema',
        postgres_conn_id='pagila_conn',
        sql='include/pagila-schema-final.sql',
    )

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

    sakila_data = BashOperator(
        task_id='load_sakila_data',
        bash_command='psql "postgresql://airflow:airflow@postgres/airflow" -f /opt/airflow/dags/include/sakila-data-final.sql'
    )

    #airbyte
    trigger_airbyte_sync = PythonOperator(
        task_id='trigger_airbyte_sync',
        python_callable=trigger_airbyte_via_connection,
    )


    pagila_schema >> pagila_data >> trigger_airbyte_sync
    sakila_schema >> sakila_data >> trigger_airbyte_sync

setup_db_dag()