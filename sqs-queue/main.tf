resource "aws_sqs_queue" "app" {
  name = "${var.prefix}-events"
}
