provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region
}

resource "google_pubsub_topic" "topic" {
  name = var.topic_name
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_id
  location   = var.region
}

resource "google_storage_bucket_notification" "notification" {
  bucket         = google_storage_bucket.bucket.name
  topic          = google_pubsub_topic.topic.id
  event_types    = ["OBJECT_FINALIZE"]
  payload_format = "JSON_API_V1"
}

output "bucket_name" {
  value = google_storage_bucket.bucket.name
}

output "pubsub_topic" {
  value = google_pubsub_topic.topic.id
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.dataset.dataset_id
}

resource "google_storage_bucket_object" "function" {
  name   = "cloud_function.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../cloud_function/cloud_function.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  runtime     = "python39"
  entry_point = "process_csv"
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.function.name
  trigger_http = false
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic.id
  }

  environment_variables = {
    DATASET_ID = google_bigquery_dataset.dataset.dataset_id
    TABLE_ID   = var.table_id
  }
}

resource "google_project_iam_binding" "pubsub_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"

  members = [
    "serviceAccount:${google_cloudfunctions_function.function.service_account_email}"
  ]
}

resource "google_project_iam_binding" "bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_cloudfunctions_function.function.service_account_email}"
  ]
}

resource "google_project_iam_binding" "storage_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_cloudfunctions_function.function.service_account_email}"
  ]
}
