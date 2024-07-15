# output "vpc_id" {
#     value = module.vpc.vpc_id
# }

# output "ig_id" {
#     value = module.vpc.ig_id
# }

# output "aws_availability_zones_info" {
#     value = module.vpc.azs
# }
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_list" {
  value = module.vpc.public_subnet_ids
}
output "private_subnet_list" {
  value = module.vpc.private_subnet_ids
}

output "igw_id" {
  value = module.vpc.igw_id
}