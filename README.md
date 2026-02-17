# terraform-aws-control-plane

Terraform module to deploy a [Gatling Control Plane](https://docs.gatling.io/reference/install/cloud/private-locations/aws/installation/) on AWS ECS Fargate.

## Features

- Deploys a Gatling Control Plane as an ECS Fargate service
- Configures [Private Locations](https://docs.gatling.io/reference/install/cloud/private-locations/aws/configuration/) for load generator provisioning on EC2
- Optional [Private Packages](https://docs.gatling.io/reference/install/cloud/private-locations/private-packages/) support via S3
- Optional [Git integration](https://docs.gatling.io/reference/execute/cloud/user/build-from-sources/) for building simulations from sources
- Custom CA certificates support
- Least-privilege IAM policies created automatically

## Prerequisites

- Terraform `>= 1.0`
- AWS provider
- Existing VPC, subnets, and security groups
- A Gatling control plane token stored in AWS Secrets Manager

> [!IMPORTANT]
> This module does **not** create any networking resources (VPC, subnets, security groups, etc.). These must be provided as inputs.

## Examples

- [Complete example](example/)

## Requirements

| Name                                                          | Version |
|---------------------------------------------------------------|---------|
| [terraform](https://www.terraform.io/)                        | >= 1.0  |
| [aws](https://registry.terraform.io/providers/hashicorp/aws/) | >= 4.0  |

## Providers

| Name                                                          |
|---------------------------------------------------------------|
| [aws](https://registry.terraform.io/providers/hashicorp/aws/) |

## Resources

| Name                             | Type     |
|----------------------------------|----------|
| `aws_ecs_cluster`                | resource |
| `aws_ecs_task_definition`        | resource |
| `aws_ecs_service`                | resource |
| `aws_iam_role`                   | resource |
| `aws_iam_policy`                 | resource |
| `aws_iam_role_policy_attachment` | resource |

## Documentation

- [AWS Private Locations — Installation](https://docs.gatling.io/reference/install/cloud/private-locations/aws/installation/)
- [AWS Private Locations — Configuration](https://docs.gatling.io/reference/install/cloud/private-locations/aws/configuration/)
- [Private Packages](https://docs.gatling.io/reference/install/cloud/private-locations/private-packages/)
- [Build from Sources](https://docs.gatling.io/reference/execute/cloud/user/build-from-sources/)

## License

Apache 2.0 — see [LICENSE](LICENSE) for details.
