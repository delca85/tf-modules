resource "aws_s3_bucket" "app" {
  bucket = "${var.app_name}-data"
}
