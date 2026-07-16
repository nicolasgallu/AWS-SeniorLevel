resource "aws_s3_bucket" "example-nicolas" {
  bucket = "my-tf-test-riogrande-tierradelfuego97-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}