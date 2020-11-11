resource "aws_s3_bucket" "lambda_bucket" {
    bucket  = var.s3_bucket_name 
    acl     = "private"

    tags = {
        Name        = "Dev Bucket"
        Environment = "Dev"
    }
}

locals {
    package_json = jsondecode(file("../../package.json"))
    build_folder = "../../deploy"
}

resource "aws_s3_bucket_object" "lambda_docdb_test" {
    bucket = "${aws_s3_bucket.lambda_bucket.id}"
    key = "main-${local.package_json.version}"
    source = "${local.build_folder}/main-${local.package_json.version}.zip"
    etag = "${filemd5("./${local.build_folder}/main-${local.package_json.version}.zip")}"
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_lambda_function" "docdb_lambda_read" {
    function_name = "${var.lambda_func_name}-read"
    s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key = "${aws_s3_bucket_object.lambda_docdb_test.id}"
    handler = "dist/index.handler"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    timeout = 300

    source_code_hash = "${filebase64sha256("${local.build_folder}/main-${local.package_json.version}.zip")}"

    runtime = "nodejs12.x"
    depends_on = [
        "aws_iam_role_policy_attachment.attach_lambda_role_logs",
        "aws_iam_role_policy_attachment.attach_lambda_role_eni",
        "aws_cloudwatch_log_group.sample_log_group_read"
    ]
    vpc_config {
        subnet_ids         = [
            var.db_subnet_1a_id,
            var.db_subnet_1b_id
        ]
        security_group_ids = [var.default_sg_custom_id]
    }

    environment {
        variables = {
            DB_ENDPOINT     = var.docdb_cluster_endpoint
            DB_USER         = var.docdb_cluster_username
            DB_PASSWORD     = var.docdb_cluster_password 
            DB_OPERATION    = "read" 
        }
    }
}

resource "aws_lambda_function" "docdb_lambda_insert" {
    function_name = "${var.lambda_func_name}-insert"
    s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key = "${aws_s3_bucket_object.lambda_docdb_test.id}"
    handler = "dist/index.handler"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    timeout = 300

    source_code_hash = "${filebase64sha256("${local.build_folder}/main-${local.package_json.version}.zip")}"

    runtime = "nodejs12.x"
    depends_on = [
        "aws_iam_role_policy_attachment.attach_lambda_role_logs",
        "aws_iam_role_policy_attachment.attach_lambda_role_eni",
        "aws_cloudwatch_log_group.sample_log_group_insert"
    ]
    vpc_config {
        subnet_ids         = [
            var.db_subnet_1a_id,
            var.db_subnet_1b_id
        ]
        security_group_ids = [var.default_sg_custom_id]
    }

    environment {
        variables = {
            DB_ENDPOINT     = var.docdb_cluster_endpoint
            DB_USER         = var.docdb_cluster_username
            DB_PASSWORD     = var.docdb_cluster_password 
            DB_OPERATION    = "insert" 
        }
    }
}

resource "aws_cloudwatch_log_group" "sample_log_group_read" {
    name = "/aws/lambda/${var.lambda_func_name}-read"
    retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "sample_log_group_insert" {
    name = "/aws/lambda/${var.lambda_func_name}-insert"
    retention_in_days = 1
}

data "aws_iam_policy_document" "lambda_cw_log_policy" {
    version = "2012-10-17"
    statement {
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        effect = "Allow"
        resources = ["arn:aws:logs:*:*:*"]
    }
}

data "aws_iam_policy_document" "lambda_eni_policy" {
    version = "2012-10-17"
    statement {
        actions = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
        ]
        effect = "Allow"
        resources = ["*"]
    }
}

resource "aws_iam_policy" "lambda_logging" {
    name = "lambda_logging"
    path = "/"
    description = "IAM Policy for logging from a lambda"

    policy = data.aws_iam_policy_document.lambda_cw_log_policy.json
}

resource "aws_iam_policy" "lambda_vpc_eni" {
    name = "lambda_vpc_eni"
    path = "/"
    description = "IAM Policy for logging from a lambda"

    policy = data.aws_iam_policy_document.lambda_eni_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_role_logs" {
    role = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_iam_role_policy_attachment" "attach_lambda_role_eni" {
    role = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_vpc_eni.arn}"
}
