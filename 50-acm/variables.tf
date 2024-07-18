variable "project_name" {
    default = "expense"
}
variable "environment" {
    default = "dev"
}
variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
    component = "backend"
  }
}
variable "zone_name" {
  default = "srinath.online"
}
variable "zone_id" {
  default = "Z097760412NZYP4P1P7PG"
}