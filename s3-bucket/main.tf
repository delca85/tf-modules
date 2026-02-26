resource "aws_s3_bucket" "app" {
  bucket = "${var.prefix}-data"
}
