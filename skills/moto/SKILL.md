---
name: moto
description: Use the local `moto` CLI (Moto AWS mock in Docker) to run, test, or plan/apply AWS code locally with no cost and no real account. Use when the user wants to try Terraform, aws CLI, or AWS SDK code locally, mentions moto or a local/mock AWS endpoint, or when code would otherwise need real AWS credentials to test.
---

# moto: local AWS in Docker

`moto` runs the Moto AWS mock server on `http://localhost:5555`. Use it instead of real AWS for local testing. Never use real AWS credentials or a real account for this.

Facts: port **5555** (not 5000), credentials `test`/`test`, region `us-east-1`, state is **ephemeral** (lost on stop, wiped by reset). Moto is a mock: Lambda/RDS etc. do not run real workloads and behavior can differ from real AWS, so say so when results may not transfer to production.

## Steps

1. Check the CLI exists: `command -v moto`. If missing, tell the user to install it from https://github.com/tassan/moto-cli (symlink the `moto` script onto PATH); needs Docker running and `curl`.
2. `moto start` (idempotent, safe every time; also creates the `moto` aws profile).
3. Use it:
   - aws CLI: `moto aws <args>` (same as `aws --profile moto <args>`)
   - SDKs and other tools: `eval "$(moto env)"` exports `AWS_ENDPOINT_URL` and dummy creds for the current shell
   - Terraform: configure the provider (below)
4. Clean slate between runs: `moto reset`. Done: `moto stop` only if the user wants the container gone.
5. Problems: `moto doctor` (docker, aws CLI, profile, port conflicts, health) and `moto logs`.

Other commands: `moto status`, `moto info` (endpoint, examples, Terraform block), `moto restart`, `moto update`, `moto version`.

## Terraform

Point the AWS provider at moto and list every service the config uses in `endpoints`. Do not use `tflocal` (it targets LocalStack).

```hcl
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  endpoints {
    s3  = "http://localhost:5555"
    sqs = "http://localhost:5555"
    # one line per service used
  }
}
```

## Gotchas

- Run `moto start` before `terraform apply` or tests; a stopped server gives connection-refused.
- After `moto stop` or `moto reset`, delete local `terraform.tfstate`, or Terraform thinks resources still exist.
- S3 bucket names must be 3+ chars and DNS-valid even in moto.
- SDK ignores the endpoint: use `eval "$(moto env)"` or pass the endpoint to the client. aws CLI v1 ignores profile `endpoint_url`.
- Some resources are slow (SQS queue creation ~25 s in Terraform); not a hang.
- Port in use: `MOTO_PORT=<free port> moto start`, then update provider endpoints to match. Other overrides: `MOTO_REGION`, `MOTO_IMAGE`, `MOTO_NAME`, `MOTO_PROFILE`.
