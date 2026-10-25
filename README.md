# moto-cli

[![ci](https://github.com/tassan/moto-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/tassan/moto-cli/actions/workflows/ci.yml)

Local AWS endpoint in one command. Runs [Moto](https://github.com/getmoto/moto) in Docker, controlled by a native bash CLI. No Python or moto install on the host.

## Why

Made to study, test and try Terraform against AWS quickly and without the risk of accidentally running up a big AWS bill. Everything runs locally against a mock, so a bad `terraform apply` costs nothing.

> **Vibecoded.** This project was vibecoded with an AI assistant, to move fast on that goal. It is a small convenience script, not battle-tested software: read it before trusting it, and expect rough edges. Moto is a mock, so behavior can differ from real AWS; verify against a real account before relying on anything in production.

## Requirements

- Docker (Docker Desktop, Colima, OrbStack, ...)
- `curl`
- AWS CLI v2 (optional, for the `moto aws` shortcut and the auto-created profile)

## Install

```sh
git clone https://github.com/tassan/moto-cli.git ~/GitHub/moto-cli
ln -s ~/GitHub/moto-cli/moto ~/.local/bin/moto   # any dir on your PATH
```

## Usage

```
moto start      # run server, create `moto` aws profile, print info
moto stop       # remove container (state is lost)
moto restart
moto status
moto info       # endpoint, examples, Terraform provider snippet
moto env        # eval "$(moto env)" to export AWS_* vars for SDKs
moto reset      # wipe all state, keep server running
moto logs [-f]
moto aws ...    # same as: aws --profile moto ...
moto update     # pull latest image, restart if running
moto doctor     # check docker, aws CLI, profile, port, health
moto version    # print moto-cli version
```

Example:

```sh
moto start
moto aws s3 mb s3://test-bucket
moto aws s3 ls
moto reset
```

## Terraform

Plain `terraform` (or OpenTofu) works against moto; no wrapper like `tflocal` is needed. Point the AWS provider at the moto endpoint:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "moto_endpoint" {
  default = "http://localhost:5555" # change if you set MOTO_PORT
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # add every service you use
  endpoints {
    s3       = var.moto_endpoint
    sqs      = var.moto_endpoint
    dynamodb = var.moto_endpoint
    iam      = var.moto_endpoint
    sts      = var.moto_endpoint
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = "demo-bucket"
}

resource "aws_sqs_queue" "demo" {
  name = "demo-queue"
}
```

```sh
moto start
terraform init
terraform apply -auto-approve
moto aws s3 ls          # demo-bucket
moto aws sqs list-queues
terraform destroy -auto-approve
moto reset              # drop leftover state (terraform state is not moto's)
```

`moto info` prints a ready-to-paste provider block for the current port. State is ephemeral, so after `moto stop`/`moto reset` delete your local `terraform.tfstate` or Terraform will think resources still exist.

## Configuration

Environment variables:

| var | default |
|---|---|
| `MOTO_PORT` | `5555` |
| `MOTO_REGION` | `us-east-1` |
| `MOTO_IMAGE` | `motoserver/moto:latest` |
| `MOTO_NAME` | `moto` (container name) |
| `MOTO_PROFILE` | `moto` (aws profile name) |

Notes:

- Default port is 5555, not Moto's 5000: macOS AirPlay Receiver listens on 5000.
- Credentials are dummy (`test` / `test`).
- State is ephemeral. It is lost on `stop`; use `reset` for a clean slate.
- `moto start` writes a `moto` profile (keys, region, `endpoint_url`) to `~/.aws`.
- Moto mocks the AWS API; services like Lambda or RDS do not run real workloads.

## Troubleshooting

Run `moto doctor`. Common causes:

- `docker daemon not running`: start Docker Desktop / Colima / OrbStack.
- `port ... in use`: another process owns the port; set `MOTO_PORT=<free port>`.
- SDK ignores the endpoint: use `eval "$(moto env)"` (`AWS_ENDPOINT_URL` needs a recent SDK), or set the endpoint per client.
- aws CLI v1: profile `endpoint_url` is unsupported, use `moto env` instead.

## For AI agents

[AGENTS.md](AGENTS.md) teaches coding agents (Claude Code, Codex, Cursor, Copilot, Gemini CLI, ...) how to use `moto`: rules, workflow, Terraform setup and gotchas. [CLAUDE.md](CLAUDE.md) just imports it for Claude Code.

Agents only read these files inside this repo, so to make an agent use moto in **your own** project, add it there. Pick one:

Copy the full instructions into the project (works with any agent):

```sh
curl -fsSL https://raw.githubusercontent.com/tassan/moto-cli/main/AGENTS.md >> AGENTS.md
```

Or add a short pointer to the project's `AGENTS.md` / `CLAUDE.md`:

```md
## AWS testing
Never use real AWS credentials locally. Use the `moto` CLI (https://github.com/tassan/moto-cli):
`moto start`, `moto aws <cmd>`, `eval "$(moto env)"`, `moto reset`, `moto stop`, `moto doctor`.
Endpoint is http://localhost:5555, creds test/test. Point the Terraform AWS provider at it.
Full agent instructions: https://raw.githubusercontent.com/tassan/moto-cli/main/AGENTS.md
```

For Claude Code you can also import it directly in the project's `CLAUDE.md` with `@/path/to/moto-cli/AGENTS.md`.

## Development

```sh
shellcheck moto test/smoke.sh
./test/smoke.sh   # end-to-end, own container and profile
```

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE). Not affiliated with the Moto project or AWS.
