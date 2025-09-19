data "aws_caller_identity" "current" {}

resource "aws_s3_account_public_access_block" "disable_block" {
  account_id = data.aws_caller_identity.current.account_id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "media" {
  bucket = "image-video-gallery-part69"

  force_destroy = true   # <── ensures all objects are deleted on destroy
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.media.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::image-video-gallery-part69/*"
    }
  ]
}
POLICY
}
