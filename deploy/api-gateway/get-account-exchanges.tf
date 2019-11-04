resource "aws_api_gateway_resource" "account_exchanges" {
  path_part = "account_exchanges"
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "account_exchanges_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.account_exchanges.id
  http_method = "GET"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "account_exchanges_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.account_exchanges.id
  http_method = aws_api_gateway_method.account_exchanges_get.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = data.aws_lambda_function.get_account_exchanges.invoke_arn
  depends_on = ["aws_api_gateway_method.account_exchanges_get"]
}

resource "aws_lambda_permission" "get_account_exchanges_lambda_permission" {
  statement_id = "hallebarde-${var.env}-allow-get_account_exchanges"
  action = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.get_account_exchanges.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.deployment.execution_arn}/*/account_exchanges"
}

