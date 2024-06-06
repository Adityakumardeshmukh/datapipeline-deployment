from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def example_task():
    print("Example Airflow DAG Task")

with DAG('example_dag', default_args=default_args, schedule_interval=timedelta(days=1)) as dag:
    run_example_task = PythonOperator(
        task_id='example_task',
        python_callable=example_task,
    )
