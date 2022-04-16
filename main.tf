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

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "pipeline-example-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "pipeline-example-cluster"
  kubernetes_version  = "1.21.9"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

variable "acr_username" {
  description = "acr username"
}

variable "acr_token" {
  description = "acr token"
}

variable "acr_server" {
  description = "acr server"
}

resource "azurerm_container_group" "aci-backend" {
  name                = "pipeline-example-backend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "pipeline-example-backend"
  os_type             = "Linux"

  container {
    name   = "pipeline-example-backend"
    image  = "mcr.microsoft.com/pipelinexample/pipeline-example-backend"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  image_registry_credential {
    username  = var.acr_username
    password  = var.acr_token
    server    = var.acr_server
  }
}