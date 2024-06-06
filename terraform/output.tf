output "bucket_name" {
  value = google_storage_bucket.bucket.name
}

output "pubsub_topic" {
  value = google_pubsub_topic.topic.id
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.dataset.dataset_id
}
