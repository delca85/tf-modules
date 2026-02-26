output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.app.url
}
