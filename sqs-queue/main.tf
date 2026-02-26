resource "aws_sqs_queue" "app" {
  name = "${var.app_name}-events"
}
