terraform {
  backend "s3" {
    bucket         = "org-terraform-state-environment"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true 
  }
}
