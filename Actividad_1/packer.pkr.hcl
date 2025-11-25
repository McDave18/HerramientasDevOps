packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

#Variables para AWS
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

#Variables para DO
variable "do_api_token" {
  type      = string
  sensitive = true
  default   = ""          
}

variable "do_region" {
  type    = string
  default = "nyc3"
}

#Builder de AWS
source "amazon-ebs" "node_nginx" {
  region                      = var.aws_region
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  ami_name                    = "build-actividad-1-{{timestamp}}"
  ami_description             = "MV multinube para actividad 1 de Herramientas DevOps"
  associate_public_ip_address = true

  tags = {
    Name        = "build-actividad-1"
    Project     = "Herramientas DevOps"
    Environment = "Lab"
  }
}

#Builder para DO

source "digitalocean" "node_plus_do" {
  api_token    = var.do_api_token
  image        = "ubuntu-22-04-x64"
  region       = var.do_region
  size         = "s-1vcpu-1gb"
  ssh_username = "root"

  snapshot_name = "build-actividad-1-do-{{timestamp}}"

  tags = ["herramientas", "DevOps", "actividad1", "DavidHuerta"]
}

#Build multinube

build {
  name = "build-multinube-aws-do"

  sources = [
    "source.amazon-ebs.node_nginx",
    "source.digitalocean.node_plus_do"
  ]

  # De momento un solo script para los dos.
  provisioner "shell" {
    script = "scripts/install_node_nginx.sh"
  }
}
