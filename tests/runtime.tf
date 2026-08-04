terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.80.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "2.10.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "0.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
