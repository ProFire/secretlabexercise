# Secret Lab exercise

This repository is done for Secret Lab's coding interview.

## Pre-requisites to installation

- You must have an AWS User Account with Access Key and Secret
- Have AWS CLI installed on your machine
- Have AWS configure done with your ACCESS KEY and SECRET on your machine
- Have Terraform installed

## Installation

Navigate to the ./build/terraform folder and run the following command to set up your AWS infrastructure and CICD pipeline

```bash
terraform apply
```

Go to your AWS console and navigate to your developer tools to setup your _code star connection_. You need connect your Github Account to your code star in order to run this repository.

Then go to your _CodePipeline_ and do a "__release change__" on "__secretlabexercise-codepipeline__" pipeline.

## AWS Infrastructure

- 2 public subnets in 2 Availability Zones for High Availability deployment
- 2 private subnets in 2 Availability Zones for High Availability deployment
- RDS is deployed in private subnet for security
- Laravel is deployed in Fargate in public subnet, behind a [load balancer](http://secretlabexercise-lb-1171822883.ap-southeast-1.elb.amazonaws.com/)
- CICD pipeline is automatically triggered upon git push

## Usage

### Get latest object

Syntax: `GET` /api/object/${arg1}?timestamp=${arg2}

#### Parameters
- `arg1` `string` `required` The object name or the key
- `arg2` `string` `optional` The timestamp or the datetime to get the object on or before

#### Returns
`json` The string or the json string if found. It will return 404 if the object is not found.

#### Examples:
```bash
curl --location --request GET 'http://secretlabexercise-lb-1171822883.ap-southeast-1.elb.amazonaws.com/api/object/mykey'

curl --location --request GET 'http://secretlabexercise-lb-1171822883.ap-southeast-1.elb.amazonaws.com/api/object/mykey?timestamp=1633296600'

curl --location --request GET 'http://secretlabexercise-lb-1171822883.ap-southeast-1.elb.amazonaws.com/api/object/mykey?timestamp=2021-10-03 21:30:00'
```
- - - -
### Add object

Syntax: `POST` /api/object

#### PostBody
- `json` A list of key-value pairs to store. Multiple pairs allowed

#### Returns
`json` A success message

#### Example:
```bash
curl --location --request POST 'http://secretlabexercise-lb-1171822883.ap-southeast-1.elb.amazonaws.com/api/object' \
    --header 'Content-Type: text/plain' \
    --data-raw '{"mykey":"value1","anotherKey":"{a:1,b:2}"}'
```
- - - -
### List all objects

Syntax: `GET` /api/object/get_all_records

#### Returns
`json` A complete list of records in database, including past entries

#### Example:
```bash
curl --location --request GET 'http://secretlabexercise-lb-1171822883.ap-southeast-1.elb.amazonaws.com/api/object/get_all_records'
```

## Shortcuts
Due to circumstance, time, and cost constraints, the following shortcuts were taken and how in actual production I would have done differently:

- I would done 3 or more git branches in an actual git for proper deployment cycle
  - release/prod
  - release/uat
  - release/dev
- I would have done feature branching that corresponds to JIRA or Trello tickets and do _Pull Request_ for code reviews, like:
  - feature/ABC-1
  - hotfix/XYZ-2
- There is only 1 environment in AWS. Ideally, there should be 3, corresponding to the 3 release branches in git. I didn't do it for cost-savings since the 3 environments are identical.
- There should be an independent terraform git repo and its own pipeline in AWS to ensure a more secure AWS account. It will also allow multiple DevOps to modify the terraform git repo and deploy with S3 state storage and DynamoDB for state-locking. See: [https://learn.hashicorp.com/tutorials/terraform/aws-remote?in=terraform/aws-get-started](https://learn.hashicorp.com/tutorials/terraform/aws-remote?in=terraform/aws-get-started)
- The password for database should not have been stored in terraform script or in the codes. It should have been stored in [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [AWS Parameter Store instead](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).
- The ECS cluster should have auto-scaling feature so that it can scale the app with varying traffic loads.
- The RDS database should have been [Aurora Serverless v1](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) and have CloudWatch schedule a regular ping of about 5 minutes. This way, the database can scale with the ECS cluster without Aurora going through cold start.
- The CICD deployment should be Blue/Green instead.
- No VPN and VPN gateway was created. I would have either used [OpenVPN](https://shurn.me/blog/2016-12-19/creating-a-hybrid-data-centre-with-openvpn) or [WireGuard](https://www.wireguard.com/) so that the private subnet is accessible from corporate network. That also means the RDS is not accessible unless there is a VPN setup or there is an EC2 instance in Public Subnet to SSH/RDP into.
- No redis cache was created to store PHP sessions, since the exercise requirement didn't require session storage and I wanted to save on cost. I would have created a [ElastiCache Redis Cluster](https://aws.amazon.com/elasticache/redis/) to store sessions, so that the PHP app is stateless.
- Normally, test isn't done on production environment, but on uat and development environment. But since I only created 1 environment, the test is done on production environment.
- Given enough time, I would produce the Code Coverage report in a centralised location, like S3.
- I would have configured a DNS like secretlab.shurn.me and procured an SSL cert on the domain, given enough time. My own domain, [https://shurn.me/](https://shurn.me/) already has an SSL cert.
