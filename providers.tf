terraform {
  required_version = "~> 0.12"
}
provider "aws" {
  version = "~> 2.7"
}
provider "kubernetes" {
  version = ">= 1.4.0"
}
provider "helm" {
  version = ">= 0.7.0"
}
