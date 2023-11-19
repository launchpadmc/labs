resource "aws_s3_bucket" "labs_bucket" {
  bucket = "my-labs-test-bucket"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_ownership_controls" "labs_bucket" {
  bucket = aws_s3_bucket.labs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "acl_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.labs_bucket]
  bucket     = aws_s3_bucket.labs_bucket.id
  acl        = "private"
}
resource "aws_s3_bucket_versioning" "versioning_labs_bucket" {
  bucket = aws_s3_bucket.labs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
################## Upload multiple files into S3 bucket #################
# generate 100 files: for i in {0..100}; do dd if=/dev/urandom bs=510 count=$i of=file$i; done
resource "aws_s3_object" "s3_multiples_files" {
  bucket   = aws_s3_bucket.labs_bucket.id
  for_each = fileset("/Users/v.sushchevich/Downloads/100", "*")
  key      = each.value
  source   = "/Users/v.sushchevich/Downloads/100/${each.value}"
  etag     = filemd5("/Users/v.sushchevich/Downloads/100/${each.value}")
}


locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.labs_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  comment             = "cloudfront distribution"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.labs_bucket.id

  rule {
    id = "files"

    expiration {
      days = 2
    }

    filter {
      and {
        prefix = "my-labs-test-bucket/"

        tags = {
          rule      = "files"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 1
      storage_class = "GLACIER"
    }
  }
}
