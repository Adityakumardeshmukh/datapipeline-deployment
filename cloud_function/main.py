import base64
import json
import os
from google.cloud import storage, bigquery

def process_csv(event, context):
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    attributes = event.get('attributes', {})
    bucket_name = attributes.get('bucketId')
    file_name = attributes.get('objectId')

    if not bucket_name or not file_name:
        print("Missing necessary information in Pub/Sub message")
        return

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    # Download the CSV file
    content = blob.download_as_text()

    # Parse CSV file content
    rows = content.splitlines()

    # Initialize BigQuery client
    bigquery_client = bigquery.Client()
    dataset_id = os.getenv('DATASET_ID')
    table_id = os.getenv('TABLE_ID')

    table_ref = bigquery_client.dataset(dataset_id).table(table_id)
    table = bigquery_client.get_table(table_ref)

    # Prepare data for BigQuery
    rows_to_insert = [
        dict(zip([field.name for field in table.schema], row.split(',')))
        for row in rows
    ]

    # Insert data into BigQuery
    errors = bigquery_client.insert_rows_json(table, rows_to_insert)

    if errors:
        print("Errors occurred while inserting rows: {}".format(errors))
    else:
        print("Data inserted successfully")
