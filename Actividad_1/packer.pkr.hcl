packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }

    # 🔵 AZURE PLUGIN
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

#Variable de AWS
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-0fc5d935ebf8bc3bc" 
}

variable "instance_type" {
  type    = string
  default = "t3.nano"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

#Variables de Azure
variable "azure_subscription_id" {
  type    = string
  default = ""
}

variable "azure_client_id" {
  type    = string
  default = ""
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
  default   = ""  
}

variable "azure_tenant_id" {
  type    = string
  default = ""
}

variable "azure_resource_group" {
  type    = string
  default = "rg-unir-herramientasdevops"
}

variable "azure_location" {
  type    = string
  default = "eastus"
}

#Build AWS
source "amazon-ebs" "node_nginx" {
  region                  = var.aws_region
  source_ami              = var.source_ami
  instance_type           = var.instance_type
  ssh_username            = var.ssh_username
  ami_name                = "deploy-actividad-1-{{timestamp}}"
  ami_description         = "MV con Node.js y Nginx para actividad 1 de Herramientas DevOps"
  associate_public_ip_address = true

  tags = {
    Name        = "deploy-actividad-1"
    Project     = "Herramientas DevOps"
    Environment = "Lab"
  }
}

#Builde AZURE
source "azure-arm" "node_nginx_azure" {

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"
  location  = var.azure_location
  vm_size   = "Standard_B1s"   #Equivalente a t3.nano de aws elegido
  managed_image_resource_group_name = var.azure_resource_group
  managed_image_name                = "deploy-actividad-1-azure-{{timestamp}}"

  azure_tags = {
    Project     = "Herramientas DevOps"
    Environment = "Lab"
  }
}

build {
  name = "actividad-1-multicloud"

  # Ejecuta AMBAS fuentes (AWS y Azure)
  sources = [
    "source.amazon-ebs.node_nginx",
    "source.azure-arm.node_nginx_azure"
  ]

  provisioner "shell" {
    script = "scripts/install_node_nginx.sh"
  }
}
