# predictmind-infra

Infrastructure for the **PredictMind** platform — local development stack and AWS deployment (Terraform).

Part of the PredictMind platform (microservices architecture). Product and architecture documentation lives in the private [`predictmind/app`](https://github.com/predictmind/app) repository.

## Repositories in the platform

| Repo | Role | Port |
| --- | --- | --- |
| [predictmind-web](https://github.com/predictmind/predictmind-web) | Next.js frontend | 3000 |
| [predictmind-gateway](https://github.com/predictmind/predictmind-gateway) | API gateway | 3001 |
| [predictmind-auth-service](https://github.com/predictmind/predictmind-auth-service) | Auth & users | 3002 |
| [predictmind-market-service](https://github.com/predictmind/predictmind-market-service) | Market data & indicators | 3003 |
| [predictmind-news-service](https://github.com/predictmind/predictmind-news-service) | News & sentiment | 3004 |
| [predictmind-strategy-service](https://github.com/predictmind/predictmind-strategy-service) | Strategy generation & ranking | 3005 |
| [predictmind-backtest-service](https://github.com/predictmind/predictmind-backtest-service) | Backtesting | 3006 |
| [predictmind-paper-service](https://github.com/predictmind/predictmind-paper-service) | Paper trading | 3007 |
| [predictmind-reporting-service](https://github.com/predictmind/predictmind-reporting-service) | Reporting | 3008 |
| [predictmind-ai](https://github.com/predictmind/predictmind-ai) | AI services (FastAPI) | 8000 |

## Local development

Clone all service repos as siblings of this one, then:

```bash
docker compose up --build
```

This starts every service plus PostgreSQL (TimescaleDB), Redis, and MinIO. The web app is at <http://localhost:3000>, the gateway at <http://localhost:3001/api/v1>.

## AWS deployment (Terraform)

The `terraform/aws` stack provisions an AWS-native, container-first topology:

- **VPC** — public/private subnets across 2 AZs + NAT.
- **ECS Fargate** — one service per container; public services (gateway, web) behind an **ALB**, internal services via **Cloud Map** service discovery.
- **ECR** — one image repository per service (scan-on-push).
- **RDS PostgreSQL 17** + **ElastiCache Redis** + **S3** artifacts bucket.

```bash
cd terraform/aws
terraform init
terraform plan  -var="db_password=<secret>"
terraform apply -var="db_password=<secret>"
```

> This is a deployment **skeleton** describing the target topology. Before production: configure remote state (S3 + DynamoDB lock), an ACM certificate for the HTTPS listener, secrets via AWS Secrets Manager, autoscaling, and WAF. Never commit `.tfvars` or state.

## CI

`terraform fmt -check` and `terraform validate` run on every push and PR.

## License

Proprietary — © PredictMind. All rights reserved.
