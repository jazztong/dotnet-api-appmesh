locals {
  db_dns    = "${var.uid}-db.${aws_service_discovery_private_dns_namespace.this.name}"
  redis_dns = "${var.uid}-redis.${aws_service_discovery_private_dns_namespace.this.name}"
}

module "ecs_service" {
  for_each = {
    order = {
      paths = ["/api/orders*"]
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/order_api"
      environments = {
        ConnectionStrings__MyDb = "server=${local.db_dns};port=3306;user=root;password=mypassword;database=Orders;"
        Url__Product            = "http://${var.uid}-product.${aws_service_discovery_private_dns_namespace.this.name}"
      }
      mesh_backend = [
        "${var.uid}-product.${aws_service_discovery_private_dns_namespace.this.name}",
        local.db_dns
      ]
    }
    product = {
      paths = ["/api/products*"]
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/product_api"
      environments = {
        ConnectionStrings__MyDb    = "server=${local.db_dns};port=3306;user=root;password=mypassword;database=Products;"
        ConnectionStrings__MyRedis = local.redis_dns
      }
      mesh_backend = [
        local.db_dns,
        local.redis_dns
      ]
    }
    user = {
      paths = ["/api/users*"]
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/user_api"
      environments = {
        ConnectionStrings__MyDb = "server=${local.db_dns};port=3306;user=root;password=mypassword;database=Users;"
      }
      mesh_backend = [
        local.db_dns
      ]
    }
    db = {
      image        = "mysql"
      environments = { MYSQL_ROOT_PASSWORD = "mypassword" }
      port         = 3306
      protocol     = "tcp"
    }
    redis = {
      image    = "redis"
      port     = 6379
      protocol = "tcp"
    }
  }

  source       = "./modules/ecs"
  name         = "${var.uid}-${each.key}"
  paths        = lookup(each.value, "paths", [])
  image        = each.value.image
  inject_env   = lookup(each.value, "environments", {})
  mesh_backend = lookup(each.value, "mesh_backend", [])
  port         = lookup(each.value, "port", 80)
  protocol     = lookup(each.value, "protocol", "http")

  create_lb                      = lookup(each.value, "paths", []) == [] ? false : true
  cluster                        = aws_ecs_cluster.this.id
  lb_listener_arn                = aws_lb_listener.http.arn
  sg_id                          = aws_security_group.this.id
  task_role_arn                  = aws_iam_role.task.arn
  mesh_name                      = aws_appmesh_mesh.this.name
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.this.id
  service_discovery_namespace    = aws_service_discovery_private_dns_namespace.this.name
  depends_on = [
    aws_lb.this,
    aws_service_discovery_private_dns_namespace.this,
    aws_iam_role.task,
    aws_appmesh_mesh.this,
    aws_security_group.this,
    aws_lb_listener.http
  ]
}
