terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the website."
  type        = string
}

resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = aws_s3_bucket_website_configuration.site.index_document[0].suffix
  source       = "${path.module}/index.html"
  source_hash  = filemd5("${path.module}/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/${aws_s3_object.index.key}"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.site]
}

output "website_url" {
  description = "Public HTTP URL for the S3 website."
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}
