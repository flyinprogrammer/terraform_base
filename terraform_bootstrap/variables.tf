variable "bucket_name" {
  description = "bucket name for storing state"
}

variable "dynamodb_table_name" {
  description = "table name for dynamodb table used for state locking"
}

variable "region" {
  type    = string
  default = "us-east-2"
}
