# kiada-example

This repository contains a fully reproducible example of deploying the example
application from [Kubernetes in Action][kia].

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
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Terragrunt](https://terragrunt.gruntwork.io)

Additionally, many of the scripts expect `$AWS_PROFILE` to be configured. This
should point to a valid profile that has already been configured with
credentials.

[direnv]: https://direnv.net
[kia]: https://www.manning.com/books/kubernetes-in-action-second-edition
[nix]: https://nixos.org
