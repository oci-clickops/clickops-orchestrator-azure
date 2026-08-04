# Azure workload adapter

This Terraform root deploys project workloads into an existing Azure foundation. It creates only private Linux virtual machines and Oracle Autonomous Database resources. Resource groups, virtual networks, subnets, network security groups, IAM, and landing-zone resources are supplied through the reviewed project handoff and are never created here.

`platform-ci` checks out this adapter, generates the Azure provider and OCI Object Storage backend at runtime, and passes the project manifest as a Terraform variable file. Azure service-principal credentials remain in the runner `ARM_*` environment. Workload manifests contain resource secrets only as environment-qualified runtime placeholders.

## Manifest roots

| Resource | Terraform root | Required handed-off references |
|---|---|---|
| Private VM | `virtual_machines` | Location, resource group, subnet ID, and NSG ID |
| Oracle ADB | `oracle_autonomous_databases` | Location, resource group, delegated subnet ID, and VNet ID |

VMs use Ubuntu 22.04 LTS Gen2 and do not expose a public-IP option. The VM implementation uses the Azure Verified Module for virtual machines. The ADB implementation wraps `terraform-oci-multicloud-azure//modules/azurerm-ora-adbs` at `v0.1.2`.

Removing the last entry from a project manifest is represented by `{}`. The shared workflow retains the existing isolated state and plans the resource deletion for human review.

## Local verification

The test harness generates a credential-free provider configuration in a temporary directory and uses Terraform mock providers. It never calls Azure APIs.

```bash
tests/run-tests.sh
```
