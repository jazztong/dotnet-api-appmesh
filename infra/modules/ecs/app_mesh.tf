resource "aws_appmesh_virtual_node" "this" {
  count     = 1
  name      = var.name
  mesh_name = var.mesh_name

  spec {
    dynamic backend {
      for_each = var.mesh_backend
      content {
        virtual_service {
          virtual_service_name = backend.value
        }
      }
    }

    listener {
      port_mapping {
        port     = var.port
        protocol = var.protocol
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = var.name
        namespace_name = var.service_discovery_namespace
      }
    }

    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "this" {
  count     = 1
  name      = "${var.name}.${var.service_discovery_namespace}"
  mesh_name = var.mesh_name

  spec {
    provider {
      virtual_node {
        virtual_node_name = join("", aws_appmesh_virtual_node.this.*.name)
      }
    }
  }
}
