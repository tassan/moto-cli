# moto-cli

Local AWS endpoint in one command. Runs [Moto](https://github.com/getmoto/moto) in Docker, controlled by a native bash CLI. No Python or moto install on the host.

## Requirements

- Docker (Docker Desktop, Colima, OrbStack, ...)
- `curl`
- AWS CLI v2 (optional, for the `moto aws` shortcut and the auto-created profile)

## Install

```sh
git clone git@github.com:tassan/moto-cli.git ~/GitHub/moto-cli
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
```

Example:

```sh
moto start
moto aws s3 mb s3://test-bucket
moto aws s3 ls
moto reset
```

## Configuration

Environment variables:

| var | default |
|---|---|
| `MOTO_PORT` | `5555` |
| `MOTO_REGION` | `us-east-1` |
| `MOTO_IMAGE` | `motoserver/moto:latest` |
| `MOTO_NAME` | `moto` (container name) |

Notes:

- Default port is 5555, not Moto's 5000: macOS AirPlay Receiver listens on 5000.
- Credentials are dummy (`test` / `test`).
- State is ephemeral. It is lost on `stop`; use `reset` for a clean slate.
- `moto start` writes a `moto` profile (keys, region, `endpoint_url`) to `~/.aws`.
- Moto mocks the AWS API; services like Lambda or RDS do not run real workloads.
