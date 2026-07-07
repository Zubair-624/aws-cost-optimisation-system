# "required_providers" only takes source and version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      
    }
  }
}

provider "aws" {

  region = var.root_aws_region

  default_tags {
    tags = {
      Environment = "dev"
      CostCenter  = "learning"
      ManagedBy   = "terraform"
      Project     = "aws-cost-optimization-system"
      Owner       = "zubair mazumder"
    }
  }

}