# kiada-example

This repository contains a fully reproducible example of deploying the example
application from [Kubernetes in Action][kia]. The project is intended to be
deployed on ephermeral AWS cloud playgrounds, like those offered by
[acloudguru].

## Shell

This project is powered by [Nix]. You can enter the development shell by running
the following command from the repository root:

```
nix develop
```

If you have [direnv] installed, you can enable automatic loading/unloading of
the development shell with:

```
direnv allow
```

If you don't have Nix installed locally, you'll need to have the following
binaries available for everything to work correctly:

- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS Vault](https://github.com/99designs/aws-vault)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Terragrunt](https://terragrunt.gruntwork.io)

Additionally, many of the scripts expect `$AWS_PROFILE` to be configured. This
should point to a valid profile that has already been configured with
`aws-vault`.

## Authentication

A downside to ephemeral cloud environments is that they can be difficult to
continually setup. A simple script is offered to easily detect if the
credentials for the current profile are still valid, and if not, offer to
reconfigure them and setup the local environment:

```
./scripts/auth.sh
```

This repository assumes that `aws-vault` is being used for storing credentials.
It's considered best practice to avoid having credentials stored in plain-text
on the local filesystem. The author of this repo uses [gopass] as the backend
for `aws-vault` with the vault being protected by a hardware GPG key.

A small concession is made to reduce the headache introduced by `aws-vault`: the
above mentioned authentication script will export the credentials to the current
shell environment. This avoids having to manually prepend all appropriate
commands with `aws-vault exec`. In production environments, you should always
use this command for better isolation and protect the AWS account with MFA.

[acloudguru]: https://acloudguru.com/platform/cloud-sandbox-playgrounds
[direnv]: https://direnv.net
[gopass]: https://github.com/gopasspw/gopass
[kia]: https://www.manning.com/books/kubernetes-in-action-second-edition
[nix]: https://nixos.org
