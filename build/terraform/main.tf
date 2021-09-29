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

    tags = {
        Name = "secretlabexercise-subnet-public-a"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-public-b" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "secretlabexercise-subnet-public-b"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-private-a" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.2.0/24"

    tags = {
        Name = "secretlabexercise-subnet-private-a"
    }
}

resource "aws_subnet" "secretlabexercise-subnet-private-b" { 
    vpc_id = aws_vpc.secretlabexercise-vpc.id
    cidr_block = "10.0.3.0/24"

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
                    Service = "ecs.amazonaws.com"
                }
            },
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
    }

    source {
        type = "GITHUB"
        location = "https://github.com/ProFire/secretlabexercise.git"
        git_clone_depth = 0
    }
}

# Application blocks
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

    container_definitions = jsonencode([
    {
      name      = "secretlabexercise-ecs-container_definitions"
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

# resource "aws_ecs_service" "secretlabexercise-ecs-service" {
#     name = "secretlabexercise-ecs-service"
#     cluster = aws_ecs_cluster.secretlabexercise-ecs-cluster.id

# }