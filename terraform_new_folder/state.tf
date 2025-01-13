terraform {
  backend "s3" {
    bucket = "my-terraform-state-hb"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "s3-tf-table"
  
  }
}