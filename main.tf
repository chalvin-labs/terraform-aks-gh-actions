terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  cloud {
    organization = "chalvinco"
    workspaces {
      name = "pipeline-example"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "pipeline-example"
  location = "eastus"
}

resource "azurerm_container_registry" "acr" {
  name                = "pipelinexample"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_container_group" "aci" {
  name                = "pipeline-example-backend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "pipeline-example-backend"
  os_type             = "Linux"

  container {
    name   = "pipeline-example-backend"
    image  = "chalvinwz/pipeline-example-backend"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}