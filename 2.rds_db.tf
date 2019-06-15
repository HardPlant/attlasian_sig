# resource "aws_db_parameter_group" "confluence" {
#   name   = "conf-pg"
#   family = "mysql5.7"

#   parameter {
#     name  = "character_set_server"
#     value = "utf8"
#   }

#   parameter {
#     name  = "collation_server"
#     value = "utf8_bin"
#   }
#   parameter {
#     name  = "max_allowed_packet"
#     value = "256M"
#   }
#   parameter {
#     name  = "innodb_log_file_size"
#     value = "2GB"
#   }
#   parameter {
#     name  = "sql_mode"
#     value = "NO_AUTO_VALUE_ON_ZERO"
#   }
#   parameter {
#     name  = "tx_isolation"
#     value = "READ-COMMITTED"
#   }
#   parameter {
#     name  = "binlog_format"
#     value = "row"
#   }
# }
# resource "aws_db_parameter_group" "jira" {
#   name   = "jira-pg"
#   family = "mysql5.7"

#   parameter {
#     name  = "character_set_server"
#     value = "utf8mb4"
#   }

#   parameter {
#     name  = "innodb_default_row_format"
#     value = "DYNAMIC"
#   }
#   parameter {
#     name  = "innodb_large_prefix"
#     value = "ON"
#   }
#   parameter {
#     name  = "innodb_file_format"
#     value = "Barracuda"
#   }
#   parameter {
#     name  = "innodb_log_file_size"
#     value = "2GB"
#   }
#   parameter {
#     name  = "sql_mode"
#     value = "NO_AUTO_VALUE_ON_ZERO"
#   }
# }

# resource "aws_db_instance" "confluence" {
#   allocated_storage    = 10
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t3.micro"
#   name                 = "confjira_db"
#   username             = "tta"
#   password             = "${var.db_key}"
#   parameter_group_name = "${aws_db_parameter_group.confluence.name}"
#   publicly_accessible = true
#   # db_subnet_group_name = "${aws_db_subnet_group.default.name}"
# }

# resource "aws_db_instance" "jira" {
#   allocated_storage    = 10
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t3.micro"
#   name                 = "confjira_db"
#   username             = "tta"
#   password             = "${var.db_key}"
#   parameter_group_name = "${aws_db_parameter_group.jira.name}"
#   publicly_accessible = true
#   # db_subnet_group_name = "${aws_db_subnet_group.default.name}"
# }
