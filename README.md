### Yandex.Cloud Terraform Kafka Cluster module
#### Example

```
module "kafka" {
  source             = "github.com/darzanebor/terraform-yandex-kafka.git"
  name               = "default"
  environment        = "PRODUCTION"
  network_id         = "my-network-id"
  subnet_ids         = ["my-subnet-id-a",]

  vpc_security_groups = []
  create_default_security_group = true

  config = {
      version       = "2.8"
      brokers_count = 1
      zones         = ["ru-central1-a",]
      assign_public_ip = false
      unmanaged_topics = false
      schema_registry  = false

      resources = {
        resource_preset_id = "s2.medium"
        disk_type_id = "network-ssd"
        disk_size    = 128
      }

      kafka_config = {
          compression_type                = "COMPRESSION_TYPE_ZSTD"
          log_flush_interval_messages     = 1024
          log_flush_interval_ms           = 1000
          log_flush_scheduler_interval_ms = 1000
          log_retention_bytes             = 1073741824
          log_retention_hours             = 168
          log_retention_minutes           = 10080
          log_retention_ms                = 86400000
          log_segment_bytes               = 134217728
          log_preallocate                 = false
          num_partitions                  = 10
          default_replication_factor      = 1
          auto_create_topics_enable       = false
      }

      zookeeper = {
          resource_preset_id = "s2.micro"
          disk_type_id = "network-ssd"
          disk_size = 20
      }
  }
  users = [
    {
      name     = "producer-application"
      password = "password"
      permissions = [
        {
          topic_name = "input"
          role = "ACCESS_ROLE_PRODUCER"
        },
        {
          topic_name = "output"
          role = "ACCESS_ROLE_PRODUCER"
        },
      ]
    },
    {
      name     = "producer-consumer"
      password = "password"
      permissions = [
        {
          topic_name = "input"
          role = "ACCESS_ROLE_PRODUCER"
        }
      ]
    },
  ]
  topics = [{
      name               = "input"
      partitions         = 4
      replication_factor = 1
      config = {
        cleanup_policy        = "CLEANUP_POLICY_COMPACT"
        compression_type      = "COMPRESSION_TYPE_LZ4"
        delete_retention_ms   = 86400000
        file_delete_delay_ms  = 60000
        flush_messages        = 128
        flush_ms              = 1000
        min_compaction_lag_ms = 0
        retention_bytes       = 10737418240
        retention_ms          = 604800000
        max_message_bytes     = 1048588
        min_insync_replicas   = 1
        segment_bytes         = 268435456
        preallocate           = false  
      }
  },
  {
    name               = "output"
    partitions         = 4
    replication_factor = 1
  }]

  default_security_group_ingress = [
    {
      protocol       = "TCP"
      description    = "Allow All ingress."
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = -1
    },
  ]

  default_security_group_egress = [
    {
      protocol       = "ANY"
      description    = "Allow All egress."
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = -1
      to_port        = -1
    },
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_mdb_kafka_cluster.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_kafka_cluster) | resource |
| [yandex_mdb_kafka_topic.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_kafka_topic) | resource |
| [yandex_vpc_security_group.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | (Required) Configuration of the Kafka cluster. The structure is documented below. | `map` | `{}` | no |
| <a name="input_create_default_security_group"></a> [create\_default\_security\_group](#input\_create\_default\_security\_group) | (Optional) - Create default security group. | `bool` | `false` | no |
| <a name="input_default_security_group_egress"></a> [default\_security\_group\_egress](#input\_default\_security\_group\_egress) | (Optional) - A list of egress rules to create with default security group. | `list` | `[]` | no |
| <a name="input_default_security_group_ingress"></a> [default\_security\_group\_ingress](#input\_default\_security\_group\_ingress) | (Optional) - A list of ingress rules to create with default security group. | `list` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Deployment environment of the Kafka cluster. Can be either PRESTABLE or PRODUCTION. | `string` | `"PRODUCTION"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Cluster name. | `any` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | (Required) ID of the network, to which the Kafka cluster belongs. | `any` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Optional) IDs of the subnets, to which the Kafka cluster belongs. | `any` | `null` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | (Optional) Kafka topics to create with configuration. | `list` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | (Optional) A user of the Kafka cluster. | `list` | `[]` | no |
| <a name="input_vpc_security_groups"></a> [vpc\_security\_groups](#input\_vpc\_security\_groups) | (Optional) - Assign security groups to instance. | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_yandex_mdb_kafka_cluster"></a> [yandex\_mdb\_kafka\_cluster](#output\_yandex\_mdb\_kafka\_cluster) | n/a |
| <a name="output_yandex_mdb_kafka_topic"></a> [yandex\_mdb\_kafka\_topic](#output\_yandex\_mdb\_kafka\_topic) | n/a |
