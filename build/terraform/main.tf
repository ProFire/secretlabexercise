terraform {  
    required_providers {    
        aws = {      
            source  = "hashicorp/aws"     
            version = "~> 3.27"    
        }  
    }
    required_version = ">= 0.14.9"
}
provider "aws" {  
    profile = "default"  
    region  = "ap-southeast-1"
}

# VPC and Related

resource "aws_vpc" "secretlabexercise-vpc" { 
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "secretlabexercise-vpc"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-public-a" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-southeast-1a"

    tags = {
        Name = "secretlabexercise-subnet-public-a"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-public-b" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1b"

    tags = {
        Name = "secretlabexercise-subnet-public-b"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-private-a" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1a"

    tags = {
        Name = "secretlabexercise-subnet-private-a"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-private-b" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-southeast-1b"

    tags = {
        Name = "secretlabexercise-subnet-private-b"
    }
}

resource "aws_internet_gateway" "secretlabexercise-internet-gateway" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id

    tags = {
        Name = "secretlabexercise-internet-gateway"
    }
}

resource "aws_route_table" "secretlabexercise-route-table-public" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id

    tags = {
        Name = "secretlabexercise-route-table-public"
    }
}

resource "aws_route" "secretlabexercise-route-public" { 
    route_table_id = aws_route_table.secretlabexercise-route-table-public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secretlabexercise-internet-gateway.id
}

resource "aws_route_table_association" "secretlabexercise-route-table-association-public-a" { 
    subnet_id = aws_subnet.secretlabexercise-subnet-public-a.id
    route_table_id = aws_route_table.secretlabexercise-route-table-public.id
}

resource "aws_route_table_association" "secretlabexercise-route-table-association-public-b" { 
    subnet_id = aws_subnet.secretlabexercise-subnet-public-b.id
    route_table_id = aws_route_table.secretlabexercise-route-table-public.id
}

# Roles and Policies

resource "aws_iam_role" "secretlabexercise-iam-role-codebuild" {
    name = "secretlabexercise-iam-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "codebuild.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy" "sle-iam-role-policy-codebuild" {
    name = "sle-iam-role-policy-codebuild"
    role = aws_iam_role.secretlabexercise-iam-role-codebuild.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "*",
                ]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "secretlabexercise-iam-role-codepipeline" {
    name = "secretlabexercise-iam-role-codepipeline"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "codepipeline.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy" "sle-iam-role-policy-codepipeline" {
    name = "sle-iam-role-policy-codepipeline"
    role = aws_iam_role.secretlabexercise-iam-role-codepipeline.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "*",
                ]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "secretlabexercise-iam-role-ecs-execution" {
    name = "secretlabexercise-iam-role-ecs-execution"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "ecs.amazonaws.com",
                    Service = "ecs-tasks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy" "sle-iam-role-policy-ecs-execution" {
    name = "sle-iam-role-policy-ecs-service"
    role = aws_iam_role.secretlabexercise-iam-role-ecs-execution.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "*",
                ]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

# CICD blocks

resource "aws_codestarconnections_connection" "secretlabexercise-codestarconnections-connection" {
    name = "secretlabexercise-connection"
    provider_type = "GitHub"
}

resource "aws_ecr_repository" "secretlabexercise-ecr" {
    name = "secretlabexercise-ecr"
}

resource "aws_codebuild_project" "secretlabexercise-codebuild" {
    name = "secretlabexercise-codebuild"
    service_role = aws_iam_role.secretlabexercise-iam-role-codebuild.arn

    artifacts {
        type = "NO_ARTIFACTS"
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:4.0"
        type = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode = true

        environment_variable {
            name = "AWS_DEFAULT_REGION"
            value = "ap-southeast-1"
        }

        environment_variable {
            name  = "AWS_ACCOUNT_ID"
            value = "191234494660"
        }

        environment_variable {
            name  = "IMAGE_REPO_NAME"
            value = aws_ecr_repository.secretlabexercise-ecr.name
        }

        environment_variable {
            name  = "IMAGE_TAG"
            value = "latest"
        }

        environment_variable {
            name  = "ECS_TASK_DEFINITION_NAME"
            value = aws_ecs_task_definition.secretlabexercise-ecs-task-definition.family
        }

        environment_variable {
            name  = "ECS_CONTAINER_DEFINITION_NAME"
            value = "secretlabexercise-ecs-container-definitions"
        }

        // RDS config

        environment_variable {
            name  = "RDS_ENDPOINT"
            value = aws_db_instance.secretlabexercise-db-instance.address
        }

        environment_variable {
            name  = "RDS_USERNAME"
            value = aws_db_instance.secretlabexercise-db-instance.username
        }

        environment_variable {
            name  = "RDS_PASSWORD"
            value = aws_db_instance.secretlabexercise-db-instance.password
        }

        environment_variable {
            name  = "RDS_PORT"
            value = aws_db_instance.secretlabexercise-db-instance.port
        }
    }

    source {
        type = "GITHUB"
        location = "https://github.com/ProFire/secretlabexercise.git"
        git_clone_depth = 0
        buildspec = "/build/aws/buildspec.yml"
    }

    vpc_config {
      security_group_ids = [ aws_security_group.secretlabexercise-security-group.id ]
      subnets = [ aws_subnet.secretlabexercise-subnet-public-a.id, aws_subnet.secretlabexercise-subnet-public-b.id ]
      vpc_id = aws_vpc.secretlabexercise-vpc.id
    }
}

resource "aws_codepipeline" "secretlabexercise-codepipeline" {
    name = "secretlabexercise-codepipeline"
    role_arn = aws_iam_role.secretlabexercise-iam-role-codepipeline.arn

    artifact_store {
        type = "S3"
        location = aws_s3_bucket.secretlabexercise-s3-bucket-codepipeline.bucket
    }

    stage {
        name = "Source"

        action {
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["source_output"]

            configuration = {
                ConnectionArn = aws_codestarconnections_connection.secretlabexercise-codestarconnections-connection.arn
                FullRepositoryId = "ProFire/secretlabexercise"
                BranchName = "main"
            }
        }
    }

    stage {
        name = "Build"

        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            input_artifacts = ["source_output"]
            output_artifacts = ["build_output"]
            version = "1"

            configuration = {
                ProjectName = aws_codebuild_project.secretlabexercise-codebuild.name
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "ECS"
            input_artifacts = ["build_output"]
            version = "1"

            configuration = {
                ClusterName = aws_ecs_cluster.secretlabexercise-ecs-cluster.name
                ServiceName = aws_ecs_service.secretlabexercise-ecs-service.name
                FileName = "imagedefinitions.json"
                DeploymentTimeout = "15"
            }
        }
    }
}

resource "aws_s3_bucket" "secretlabexercise-s3-bucket-codepipeline" {
    bucket = "secretlabexercise-s3-bucket-codepipeline"
    acl = "private"
}

# Application blocks

resource "aws_security_group" "secretlabexercise-security-group" {
    name = "secretlabexercise-security-group"
    vpc_id = aws_vpc.secretlabexercise-vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        description = "HTTP"
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        description = "HTTPS"
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        description = "ALL"
    }
}

resource "aws_ecs_cluster" "secretlabexercise-ecs-cluster" {
    name = "secretlabexercise-ecs-cluster"

    setting {
        name = "containerInsights"
        value = "enabled"
    }
}

resource "aws_ecs_task_definition" "secretlabexercise-ecs-task-definition" {
    family = "secretlabexercise-ecs-task-definition"
    requires_compatibilities = [ "FARGATE" ]
    cpu = 256
    memory = 512
    network_mode = "awsvpc"
    execution_role_arn = aws_iam_role.secretlabexercise-iam-role-ecs-execution.arn
    task_role_arn = aws_iam_role.secretlabexercise-iam-role-ecs-execution.arn

    container_definitions = jsonencode([
    {
      name      = "secretlabexercise-ecs-container-definitions"
      image     = "${aws_ecr_repository.secretlabexercise-ecr.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

}

resource "aws_ecs_service" "secretlabexercise-ecs-service" {
    name = "secretlabexercise-ecs-service"
    cluster = aws_ecs_cluster.secretlabexercise-ecs-cluster.id
    task_definition = aws_ecs_task_definition.secretlabexercise-ecs-task-definition.arn
    desired_count = 2
    launch_type = "FARGATE"

    depends_on = [
        aws_lb.secretlabexercise-lb,
        aws_iam_role_policy.sle-iam-role-policy-ecs-execution
    ]

    network_configuration {
      subnets = [aws_subnet.secretlabexercise-subnet-public-a.id, aws_subnet.secretlabexercise-subnet-public-b.id]
      security_groups = [aws_security_group.secretlabexercise-security-group.id]
    }

    load_balancer {
      target_group_arn = aws_lb_target_group.secretlabexercise-lb-target-group.arn
      container_name = "secretlabexercise-ecs-container-definitions"
      container_port = 80
    }
}

resource "aws_lb" "secretlabexercise-lb" {
    name = "secretlabexercise-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.secretlabexercise-security-group.id]
    subnets = [aws_subnet.secretlabexercise-subnet-public-a.id, aws_subnet.secretlabexercise-subnet-public-b.id]
    enable_deletion_protection = false
}

resource "aws_lb_listener" "secretlabexercise-lb-listener-http" {
    load_balancer_arn = aws_lb.secretlabexercise-lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.secretlabexercise-lb-target-group.arn
    }
}

resource "aws_lb_target_group" "secretlabexercise-lb-target-group" {
    name = "secretlabexercise-lb-tg"
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = aws_vpc.secretlabexercise-vpc.id

    depends_on = [
        aws_lb.secretlabexercise-lb
    ]
}

resource "aws_db_instance" "secretlabexercise-db-instance" {
    allocated_storage = 10
    engine = "mysql"
    # engine_version = "5.7.12"
    instance_class = "db.t3.small"
    name = "secretlabexercisedbinstance"
    username = "secretlabexercise"
    password = "$uper$3cret"
    db_subnet_group_name = aws_db_subnet_group.secretlabexercise-db-subnet-group.name
}

resource "aws_db_subnet_group" "secretlabexercise-db-subnet-group" {
    name = "secretlabexercise-db-subnet-group"
    subnet_ids = [aws_subnet.secretlabexercise-subnet-private-a.id, aws_subnet.secretlabexercise-subnet-private-b.id]
}