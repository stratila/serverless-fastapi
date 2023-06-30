locals {
  response_codes = toset([
    {
      status_code = 200
      response_templates = {
        "application/json" = ""
      }
      response_models = {
        "application/json" = "Empty"
      }
      response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
      }
    }
  ])

  endpoints = toset(var.endpoints.*.path)

  methods = {
    for e in var.endpoints : "${e.method} ${e.path}" => e
  }

  responses = {
    for pair in setproduct(var.endpoints, local.response_codes) :
    "${pair[0].method} ${pair[0].path} ${pair[1].status_code}" => {
      method              = pair[0].method
      path                = pair[0].path
      method_key          = "${pair[0].method} ${pair[0].path}"
      status_code         = pair[1].status_code
      response_templates  = pair[1].response_templates
      response_models     = pair[1].response_models
      response_parameters = pair[1].response_parameters

    }
  }
}


resource "aws_api_gateway_rest_api" "api" {
  name        = "api"
  description = "API"
}

resource "aws_api_gateway_resource" "api_resource" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value
}

resource "aws_api_gateway_method" "api_method" {
  for_each = local.methods

  rest_api_id = aws_api_gateway_resource.api_resource[each.value.path].rest_api_id
  resource_id = aws_api_gateway_resource.api_resource[each.value.path].id
  http_method = each.value.method

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  for_each = local.methods

  rest_api_id = aws_api_gateway_method.api_method[each.key].rest_api_id
  resource_id = aws_api_gateway_method.api_method[each.key].resource_id
  http_method = aws_api_gateway_method.api_method[each.key].http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.fast_api_lambda.invoke_arn

}

resource "aws_api_gateway_integration_response" "api_integration_response" {
  for_each = local.responses

  rest_api_id = aws_api_gateway_integration.api_integration[each.value.method_key].rest_api_id
  resource_id = aws_api_gateway_integration.api_integration[each.value.method_key].resource_id
  http_method = each.value.method
  status_code  = each.value.status_code

  response_templates = each.value.response_templates
}


resource "aws_api_gateway_method_response" "aws_api_gateway_method_response" {
  for_each = local.responses

  rest_api_id = aws_api_gateway_integration_response.api_integration_response[each.key].rest_api_id
  resource_id = aws_api_gateway_integration_response.api_integration_response[each.key].resource_id
  http_method = each.value.method
  status_code = each.value.status_code

  response_models = each.value.response_models
  response_parameters = each.value.response_parameters
}


resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_resource.api_resource,
    aws_api_gateway_method.api_method,
    aws_api_gateway_integration.api_integration,
    aws_api_gateway_integration_response.api_integration_response,
    aws_api_gateway_method_response.aws_api_gateway_method_response,
  ]

}


resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fast_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*"

  depends_on = [aws_api_gateway_deployment.api_deployment]
}


resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

output "aws_api_gateway_stage_dev_invoke_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}
