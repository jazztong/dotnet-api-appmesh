# output "rds_port" {
#   value = aws_rds_cluster.this.port
# }

# output "rds_endpoint" {
#   value = aws_rds_cluster.this.endpoint
# }

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
