provider "aws" {
    region = "eu-west-2"
  
}

# S3 Bucket for Website Hosting
resource "aws_s3_bucket" "nextjs_bucket" {
  bucket = "nextjs-portfolio-bucket-hb"

  tags = {
    Environment = "Production"
    Project     = "NextJS Portfolio"
  }
}

# S3 Bucket Website Configuration without this I cannot create and see the index.htmla file
resource "aws_s3_bucket_website_configuration" "nextjs_website_config" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}



#ownership control
resource "aws_s3_bucket_ownership_controls" "next_js_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

# Bucket ACL
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
    depends_on = [ 
        aws_s3_bucket_ownership_controls.next_js_bucket_ownership_controls,
        aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
     ]
  bucket = aws_s3_bucket.nextjs_bucket.id
  acl = "public-read"
}

# bucket policy
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
      }
    ]
  })
}

# CloudFront

# Origin Access Identity This ensure only cloudfornt can directly access the S3 bucket
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for Next.JS portfolio site"
}
  # cloudfront distribution. this explains the origin specifiy the setting of the cloud front distriubtion origin id is unique identifier for the origin. s3 origin contains settings specific to s3 as origin
  resource "aws_cloudfront_distribution" "nextjs_distribution" {
    origin {
      domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
      origin_id = "S3-nextjs-portfolio-bucket_hb"    
      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        
      }
    }
# need to  confirm enable to allow ipv6 support for the distribution, cooment allowsd to indentify what the distribution is for, default root object specify the root object for the distribution
enabled = true
    is_ipv6_enabled = true
    comment = "next.js portfolio site"
    default_root_object = "index.html"

    default_cache_behavior {
      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods = ["GET", "HEAD"]
      target_origin_id = "S3-nextjs-portfolio-bucket_hb"

# forwaridng values to false means query string are not forwarded to the origin, which simplifies cahcing and cookies none means cookies are not forwarded
      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }
# this policy redirects viewers to https ttl is the amount of time an object is cached and this is expressed in secodns
      viewer_protocol_policy = "redirect-to-https"
      min_ttl = 0
      default_ttl = 3600
      max_ttl = 86400
    }
# the restrions will say no restriction in geography, you can create a withe or a black list
    restrictions {
        geo_restriction {
          restriction_type = "none"
        }
      
    }
    # ensures secure communitcation between users and cloudfront normaly those are SSL and TSL the default option tells to use the default certificate
    viewer_certificate {
      cloudfront_default_certificate = true
    }
    
  }

# once you apply terraform init, plan and apply go to the nextjsblog directory and run aws s3 sync ./out s3://nextjs-portfolio-bucket-hb, find the domain name with terraform show and you should see the app
# When changes are commited then apply: git init

#git add .

#git git commit -m "Your commit message here"

#git remote add origin https://github.com/zelkin2/terraform-portfolio-project

# git push -u origin main
