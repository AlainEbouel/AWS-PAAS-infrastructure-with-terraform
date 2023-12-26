resource "aws_s3_bucket" "global-infra" {
  bucket = "global-infra-${random_integer.bucket-id.result}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "random_integer" "bucket-id" {
  min = 10000000
  max = 99999999
}