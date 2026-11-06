# Azure workload adapter

This Terraform root deploys project workloads into an existing Azure foundation. It creates only private Linux virtual machines and Oracle Autonomous Database resources with private or public mTLS connectivity. Resource groups, virtual networks, subnets, network security groups, IAM, and landing-zone resources are supplied through the reviewed project handoff when required and are never created here.

`platform-ci` checks out this adapter, generates the Azure provider and OCI Object Storage backend at runtime, and passes the project manifest as a Terraform variable file. Azure service-principal credentials remain in the runner `ARM_*` environment. Workload manifests contain resource secrets only as environment-qualified runtime placeholders.

## Manifest roots

| Resource | Terraform root | Required handed-off references |
|---|---|---|
| Private VM | `virtual_machines` | Location, resource group, subnet ID, and NSG ID |
| Private Oracle ADB | `oracle_autonomous_databases` | Location, resource group, delegated subnet ID, and VNet ID |
| Public Oracle ADB with mTLS | `oracle_autonomous_databases` | Location and resource group; no subnet or VNet |

VMs use Ubuntu 22.04 LTS Gen2 and do not expose a public-IP option. The VM implementation uses the Azure Verified Module for virtual machines. The ADB implementation wraps `terraform-oci-multicloud-azure//modules/azurerm-ora-adbs` at `v0.1.2`.

## ADB connectivity

Each ADB selects `network_access: private` or `network_access: public`. Private is the default for existing manifests and requires both `subnet_id` and `virtual_network_id`. Its existing `mtls_connection_required: false` default is preserved; a private request may explicitly require mTLS.

A public request must set `network_access: public` and `mtls_connection_required: true`, and omit both network IDs or set them to `null`. Empty strings and private network references are rejected. The adapter passes null IDs and the mTLS setting to the unchanged official module. This profile permits connections from any IP address and requires a client wallet and database authentication. It does not support an IP allowlist. The request preview must state the public exposure explicitly.

Both modes can coexist in the same regional `oracle_autonomous_databases` map. Switching an existing database between private and public connectivity requires replacement; inspect the plan before approval. The wrapped module also ignores subsequent changes to some fields, including mTLS and the admin password, so those changes must not be described as supported in-place updates.

Publish the reviewed adapter and update each consuming project's immutable orchestrator pin before enabling the public catalog template. Updating only the catalog does not enable public requests on an older adapter. This change retains the upstream module version and its storage contract in whole TB; it does not add 20 GB storage support.

Removing the last entry from a project manifest is represented by `{}`. The shared workflow retains the existing isolated state and plans the resource deletion for human review.

## Local verification

The test harness generates a credential-free provider configuration in a temporary directory and uses Terraform mock providers. It never calls Azure APIs.

```bash
tests/run-tests.sh
```
