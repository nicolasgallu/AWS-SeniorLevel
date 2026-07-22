resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "pipeline-weather-data" {
  bucket  = aws_s3_bucket.data_bucket.id
  key     = "pipeline-weather-data/"
  content = ""
}

resource "aws_s3_bucket" "artifacts" {
  bucket = var.bucket_name_artifact
}

resource "aws_s3_object" "artifact_key" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "lambda-build/"
  content = ""
}


resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]

      Resource = [
        aws_s3_bucket.artifacts.arn,
        "${aws_s3_bucket.artifacts.arn}/*"
      ]
    }]
  })
}


resource "aws_codebuild_project" "lambda_build" {
  name         = "lambda-build"
  service_role = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/nicolasgallu/AWS-SeniorLevel/tree/7f7c3060c2427a204b2f979af2ffaae8cfb1b2c0/pipeline_02"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
    name = "lambda-build"
}
}


resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]

      Resource = "*"
    }]
  })
}


resource "aws_lambda_function" "test_lambda" {
  function_name = "testing"

  role = aws_iam_role.lambda_role.arn

  handler = "code.lambda_handler"

  runtime = "python3.12"

  s3_bucket = aws_s3_bucket.artifacts.bucket
  s3_key    = "lambda-build/lambda.zip"
}