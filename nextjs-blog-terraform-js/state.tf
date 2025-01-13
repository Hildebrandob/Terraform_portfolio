terraform {
  backend "s3" {
    bucket = "hb-my-tf-website-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "my-db-website-table"
  }
}
# it is recommendable to separate the rest of the data base from the structure, first create the bucket with  aws s3api create-bucket --bucket hb-my-tf-website-state --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
# remember name must be uniqu
# then deploy table with aws dynamodb create-table --table-name my-db-website-table \
#--attribute-definitions AttributeName=LockID,AttributeType=S \
#--key-schema AttributeName=LockID,KeyType=HASH \
#--provisioned-throughput ReadCapacityUnits=2,WriteCapacityUnits=2


