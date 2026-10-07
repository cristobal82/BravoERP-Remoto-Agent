# Code signing policy

BravoERP Remoto Agent is an open-source downstream project derived from
[MeshAgent](https://github.com/Ylianst/MeshAgent). Windows release artifacts are intended to be
built from this public repository by GitHub Actions. No customer configuration, credentials,
private keys, server database, or production exports belong in this repository.

Free code signing provided by [SignPath.io](https://signpath.io/), certificate by
[SignPath Foundation](https://signpath.org/).

This statement describes the intended signing process. It does not claim that current artifacts
are signed by SignPath Foundation. That claim will only be added to a release after the project is
accepted and the published artifact has a valid SignPath Foundation Authenticode signature.

## Roles

- Authors: [@cristobal82](https://github.com/cristobal82)
- Reviewers: [@cristobal82](https://github.com/cristobal82)
- Approvers: [@cristobal82](https://github.com/cristobal82)

External contributions must be reviewed before merge. Release signing requests require explicit
manual approval by an approver. Multi-factor authentication is required for repository and signing
accounts.

## Build and release integrity

- Release artifacts must be produced from a tagged commit in this public repository.
- Windows builds use the checked-in GitHub Actions workflow and Microsoft build tooling.
- Signed files must use a consistent product name and version.
- Release artifacts must include SHA-256 checksums.
- Signing credentials must never be committed to the repository.
- Production server configuration is injected or delivered separately and must not alter a signed
  executable unless the resulting file is signed again through the approved pipeline.
- Every release signing request requires manual approval.

## Scope

Only binaries built from source maintained in this repository may be submitted under this project.
Upstream or third-party binaries must not be represented as BravoERP-built artifacts.

## Reporting

Security concerns should be reported through GitHub's private vulnerability reporting feature when
available. Do not include credentials, private keys, customer data, or production configuration in
public reports.

