resource "yandex_mdb_kafka_cluster" "this" {
  name        = var.name
  environment = var.environment

  network_id  = var.network_id
  subnet_ids  = var.subnet_ids

  security_group_ids = (var.create_default_security_group && (var.default_security_group_ingress != [] || var.default_security_group_egress != [])) || var.vpc_security_groups != [] ? setunion(try([yandex_vpc_security_group.this[0].id],[]),var.vpc_security_groups) : null
  #deletion_protection
  #labels
  #maintenance_window
  dynamic "config" {
    for_each    = var.config != {} ? [var.config] : []
    iterator    = config

    content {
      version          = lookup(config.value, "version", "2.8")
      brokers_count    = lookup(config.value, "brokers_count", 1)
      zones            = lookup(config.value, "zones")
      assign_public_ip = lookup(config.value, "assign_public_ip", false)
      unmanaged_topics = lookup(config.value, "unmanaged_topics", false)
      schema_registry  = lookup(config.value, "schema_registry", false)

      kafka {
        dynamic "resources" {
          for_each    = length(keys(lookup(config.value, "resources", {}))) == 0 ? [] : [config.value.resources]
          iterator    = resource
          content {
            resource_preset_id = lookup(resource.value, "resource_preset_id", "s2.medium")
            disk_type_id       = lookup(resource.value, "disk_type_id", "network-ssd")
            disk_size          = lookup(resource.value, "disk_size", 128)
          }
        }

        dynamic "kafka_config" {
          for_each    = length(keys(lookup(config.value, "kafka_config", {}))) == 0 ? [] : [config.value.kafka_config]
          iterator    = kafka_config
          content {
            compression_type                = lookup(kafka_config.value, "compression_type", "COMPRESSION_TYPE_ZSTD")            
            log_flush_interval_messages     = lookup(kafka_config.value, "log_flush_interval_messages", 1024)
            log_flush_interval_ms           = lookup(kafka_config.value, "log_flush_interval_ms", 1000)
            log_flush_scheduler_interval_ms = lookup(kafka_config.value, "log_flush_scheduler_interval_ms", 1000)
            log_retention_bytes             = lookup(kafka_config.value, "log_retention_bytes", 1073741824)
            log_retention_hours             = lookup(kafka_config.value, "log_retention_hours", 168)
            log_retention_minutes           = lookup(kafka_config.value, "log_retention_minutes", 10080)
            log_retention_ms                = lookup(kafka_config.value, "log_retention_ms", 86400000)
            log_segment_bytes               = lookup(kafka_config.value, "log_segment_bytes", 134217728)
            log_preallocate                 = lookup(kafka_config.value, "log_preallocate", false)
            num_partitions                  = lookup(kafka_config.value, "num_partitions", 10)
            default_replication_factor      = lookup(kafka_config.value, "default_replication_factor", 1)
            auto_create_topics_enable      = lookup(kafka_config.value, "auto_create_topics_enable", false)
          }
        }
      }

      dynamic "zookeeper" {
        for_each    = lookup(config.value, "zookeeper", {}) != {} && tonumber(lookup(config.value, "brokers_count", 0)) != 1 ? [config.value.zookeeper] : []
        iterator    = zookeeper
        content {
          resources {
            resource_preset_id = lookup(zookeeper.value, "resource_preset_id", "s2.micro")
            disk_type_id       = lookup(zookeeper.value, "disk_type_id", "network-ssd")
            disk_size          = lookup(zookeeper.value, "disk_size", 20)
          }
        }
      }
    }
  }
  dynamic "user" {
    for_each    = var.users != [] ? var.users : []
    iterator    = user
    content {
      name     = lookup(user.value, "name")
      password = lookup(user.value, "password")
      dynamic "permission" {
        for_each    = length(lookup(user.value, "permissions", [])) == 0 ? [] : user.value.permissions
        iterator    = permission
        content {
          topic_name = lookup(permission.value, "topic_name")
          role       = lookup(permission.value, "role")
        }
      }
    }
  }
}

resource "yandex_mdb_kafka_topic" "this" {
  for_each           = { for k, v in var.topics : k => v if var.topics != [] }
  cluster_id         = yandex_mdb_kafka_cluster.this.id

  name               = lookup(each.value, "name")
  partitions         = lookup(each.value, "partitions", 4)
  replication_factor = lookup(each.value, "replication_factor", 1)
  
  dynamic "topic_config" {
    for_each    = length(keys(lookup(each.value, "config", {}))) == 0 ? [] : [each.value.config]
    iterator    = config
    content {
      cleanup_policy        = lookup(config.value, "cleanup_policy", "CLEANUP_POLICY_COMPACT")
      compression_type      = lookup(config.value, "compression_type", "COMPRESSION_TYPE_LZ4")
      delete_retention_ms   = lookup(config.value, "delete_retention_ms", 86400000)
      file_delete_delay_ms  = lookup(config.value, "file_delete_delay_ms", 60000)
      flush_messages        = lookup(config.value, "flush_messages", 128)
      flush_ms              = lookup(config.value, "flush_ms", 1000)
      min_compaction_lag_ms = lookup(config.value, "min_compaction_lag_ms", 0)
      retention_bytes       = lookup(config.value, "retention_bytes", 10737418240)
      retention_ms          = lookup(config.value, "retention_ms", 604800000)
      max_message_bytes     = lookup(config.value, "max_message_bytes", 1048588)
      min_insync_replicas   = lookup(config.value, "min_insync_replicas", 1)
      segment_bytes         = lookup(config.value, "segment_bytes", 268435456)
      preallocate           = lookup(config.value, "preallocate", false)
    }
  }
}

resource "yandex_vpc_security_group" "this" {
  network_id  = var.network_id
  count       = var.create_default_security_group && (var.default_security_group_ingress != [] || var.default_security_group_egress != []) ? 1 : 0
  
  dynamic "ingress" {
    for_each    = { for k, v in var.default_security_group_ingress : k => v }
    iterator    = ingress
    content {
      protocol       = lookup(ingress.value, "protocol", null)
      description    = lookup(ingress.value, "description", null)
      labels         = lookup(ingress.value, "labels", null)
      from_port      = lookup(ingress.value, "from_port", null)
      to_port        = lookup(ingress.value, "to_port", null)
      port           = lookup(ingress.value, "port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr_blocks", null)
      v6_cidr_blocks = lookup(ingress.value, "v6_cidr_blocks", null)
      security_group_id = lookup(ingress.value, "security_group_id", null)
      predefined_target = lookup(ingress.value, "predefined_target", null)
    }
  }

  dynamic "egress" {
    for_each    = { for k, v in var.default_security_group_egress : k => v }
    iterator    = egress
    content {
      protocol          = lookup(egress.value, "protocol", null)
      description       = lookup(egress.value, "description", null)
      labels            = lookup(egress.value, "labels", null)
      from_port         = lookup(egress.value, "from_port", null)
      to_port           = lookup(egress.value, "to_port", null)
      port              = lookup(egress.value, "port", null)
      v4_cidr_blocks    = lookup(egress.value, "v4_cidr_blocks", null)
      v6_cidr_blocks    = lookup(egress.value, "v6_cidr_blocks", null)
      security_group_id = lookup(egress.value, "security_group_id", null)
      predefined_target = lookup(egress.value, "predefined_target", null)
    }
  }
}