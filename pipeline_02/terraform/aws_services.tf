resource "aws_lambda_function" "send_message" {
  function_name = "send_wpp_test"

  runtime = "python3.12"
  handler = "lambda.lambda_handler"

  filename         = "../code/lambda.zip"
  source_code_hash = filebase64sha256("../code/lambda.zip")

  role = aws_iam_role.lambda_role.arn
  
  environment {
    variables = {
      WHATSAPP_TOKEN = var.whapi
      PHONE_NUMBER   = var.phone_number
    }
  }

}

resource "aws_iam_role" "lambda_role" {
  name = "test-lambda-role"

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