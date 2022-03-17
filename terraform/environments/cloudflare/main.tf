terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "rairtech"
    workspaces {
      name = "cloudflare"
    }
  }
}

provider "cloudflare" {
}

resource "cloudflare_zone" "rair-tech" {
    zone = "rair.tech"
}