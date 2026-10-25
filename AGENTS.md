# AGENTS.md

Instructions for AI coding agents. Two audiences: agents **using** `moto` to test AWS code (most common), and agents **working on** this repo (last section).

## What moto is

`moto` is a CLI that runs the [Moto](https://github.com/getmoto/moto) AWS mock server in Docker on `http://localhost:5555`. Use it instead of real AWS when running, testing or planning/applying Terraform, AWS CLI or SDK code locally. It costs nothing and cannot touch a real account.

## Rules

- **Never use real AWS credentials or a real account** for local testing. Use `moto`. Credentials are always `test` / `test`, region `us-east-1`.
- The port is **5555**, not Moto's default 5000 (macOS AirPlay owns 5000). Do not hardcode 5000.
- State is **ephemeral**: lost on `moto stop`, wiped by `moto reset`. Never treat it as persistent.
- Moto is a mock. Lambda, RDS and similar do not run real workloads, and behavior can differ from real AWS. Say so when results may not transfer to production.

## Workflow

```sh
moto status                 # running or stopped
moto start                  # idempotent; safe to call every time; also (re)creates the `moto` aws profile
moto aws s3 ls              # aws CLI against moto (= aws --profile moto ...)
eval "$(moto env)"          # export AWS_ENDPOINT_URL + dummy creds for SDKs/tools in this shell
moto reset                  # clean slate between test runs, server keeps running
moto stop                   # remove the container
moto doctor                 # diagnose: docker, aws CLI, profile, port conflicts, health
moto logs -f                # server logs
```

If `moto` is not installed, see [README.md](README.md) (symlink the `moto` script onto PATH). It needs Docker running and `curl`; the aws CLI is optional.

## Terraform

Point the AWS provider at moto. Add every service the config uses to `endpoints`. Full example in [README.md](README.md#terraform); `moto info` prints a ready-to-paste block for the current port.

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
    # ... one line per service used
  }
}
```

Do not use `tflocal`; it targets LocalStack, not moto.

## Gotchas

- Always `moto start` before `terraform apply` or tests; a stopped server gives connection-refused errors.
- After `moto stop` or `moto reset`, delete the local `terraform.tfstate`, otherwise Terraform believes resources still exist.
- S3 bucket names must be 3+ chars and DNS-valid even in moto.
- SDK ignores the endpoint → set `AWS_ENDPOINT_URL` (`eval "$(moto env)"`) or pass the endpoint to the client explicitly. aws CLI v1 ignores profile `endpoint_url`.
- Slow resources (e.g. SQS queue creation) can take ~25 s in Terraform; that is not a hang.
- Port in use → `MOTO_PORT=<free port> moto start`, and update provider endpoints to match.
- Overrides: `MOTO_PORT`, `MOTO_REGION`, `MOTO_IMAGE`, `MOTO_NAME`, `MOTO_PROFILE`.

## Working on this repo

- Single bash script `moto`; keep it dependency-light (docker, curl, optional aws CLI). Use `set -euo pipefail` style already in the file.
- Lint: `shellcheck moto test/smoke.sh` (CI enforces it; avoid `A && B || C`).
- Test: `./test/smoke.sh`. It uses its own container (`moto-smoke`), port 5599 and profile, so it is safe next to a running `moto`. Never make tests touch the user's `moto` profile.
- New command: add a `cmd_*` function, a `cmd_help` line, a `case` entry, a README row, and an `[Unreleased]` line in `CHANGELOG.md`.
- Releases: bump `VERSION` in `moto`, update `CHANGELOG.md`, wait for green CI, then tag with `gh release create vX.Y.Z`. Do not push, tag or change repo visibility without the owner asking.
