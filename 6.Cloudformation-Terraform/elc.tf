resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "redis-cache-subnet"
  subnet_ids = concat("${aws_subnet.rds.*.id}", "${aws_subnet.public.*.id}", "${aws_subnet.private.*.id}")
}

resource "aws_elasticache_replication_group" "redis_replica" {
  replication_group_id = "redis-cluster"
  description          = "Redis cluster for Hashicorp ElastiCache"
  node_type            = "cache.t4g.micro"
  port                 = 6379
  parameter_group_name = "default.redis7.cluster.on"
  security_group_ids   = [aws_security_group.web_sg.id]
  #   snapshot_retention_limit = 5
  #   snapshot_window          = "00:00-05:00"
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet.name
  automatic_failover_enabled = true
  replicas_per_node_group    = 1
  num_node_groups            = 3

}

output "redis_endpoint_address" {
  value = aws_elasticache_replication_group.redis_replica.configuration_endpoint_address
}
# redis-cli -h {redis_endpoint_address} -p 6379
###########################################################################################
resource "aws_elasticache_cluster" "memcache_replica" {
  cluster_id           = "memcache-cluster"
  engine               = "memcached"
  engine_version       = "1.6.12"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet.name
  security_group_ids   = [aws_security_group.web_sg.id]
}

output "memcache_endpoint_address" {
  value       = join("", aws_elasticache_cluster.memcache_replica.*.configuration_endpoint)
  description = "Cluster configuration endpoint"
}
#connect: telnet {memcache_endpoint_address} 11211
