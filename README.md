# Azure Orchestrator

Terraform orchestrator for Azure infrastructure using JSON configurations. Supports VMs, networks, and Oracle Autonomous Database (OracleDB@Azure).

## Quick Start

```bash
# Deploy with explicit var-files
terraform init
terraform apply \
  -var-file=config/resource-groups.json \
  -var-file=config/networks.json \
  -var-file=config/security-groups.json \
  -var-file=config/virtual-machines.json
```

Or via GitHub Actions: edit JSON files → create PR → merge to deploy.

## Supported Resources

| Resource | Create New | Use Existing |
|----------|------------|--------------|
| Resource Groups | ✅ | ✅ (via `resource_id`) |
| Virtual Networks | ✅ | ✅ (via `resource_id`) |
| Network Security Groups | ✅ | ✅ (via `resource_id`) |
| Virtual Machines | ✅ | ❌ |
| Oracle ADB-S | ✅ | ❌ |

## Configuration Examples

### Virtual Machine

```json
{
  "virtual_machines": {
    "vm-web": {
      "resource_group_key": "rg-demo",
      "network_key": "vnet-demo",
      "subnet_key": "subnet-public",
      "security_group_key": "nsg-web",
      "name": "vm-web-server",
      "size": "Standard_B1s",
      "admin_username": "azureuser",
      "ssh_key_path": "~/.ssh/azure_vm_key.pub",
      "create_public_ip": true
    }
  }
}
```

### Oracle Autonomous Database (OracleDB@Azure)

```json
{
  "oracle_autonomous_databases": {
    "adb-prod": {
      "resource_group_key": "rg-demo",
      "network_key": "vnet-demo",
      "subnet_key": "subnet-delegated",
      "name": "adb-prod-oltp",
      "db_workload": "OLTP",
      "compute_count": 2,
      "data_storage_size_in_tbs": 1,
      "license_model": "BringYourOwnLicense",
      "admin_password": "SecurePass#2024"
    }
  }
}
```

Workloads: `OLTP`, `DW`, `AJD`, `APEX`

> **Note**: ADB-S requires a delegated subnet. See [terraform-oci-multicloud-azure](https://github.com/oci-landing-zones/terraform-oci-multicloud-azure).

### Using Existing Resources

Add `resource_id` to reference existing infrastructure:

```json
{
  "resource_groups": {
    "rg-existing": {
      "name": "my-existing-rg",
      "location": "eastus",
      "resource_id": "/subscriptions/.../resourceGroups/my-existing-rg"
    }
  }
}
```

## Free Tier Compliance

Built-in validations for Azure free tier:

- **VM sizes**: `Standard_B1s`, `Standard_B2pts_v2`, `Standard_B2ats_v2`
- **Public IP**: Basic SKU only
- **Storage**: Standard_LRS, 30GB OS disk

## Backend

Uses OCI Object Storage for Terraform state. Configure via environment variables:

```bash
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."
export ARM_SUBSCRIPTION_ID="..."
export OCI_TF_STATE_BUCKET="terraform-state"
export OCI_TF_STATE_NAMESPACE="your-namespace"
```

## File Structure

```
config/
├── resource-groups.json
├── networks.json
├── security-groups.json
├── virtual-machines.json
└── oracle-autonomous-databases.json
```
