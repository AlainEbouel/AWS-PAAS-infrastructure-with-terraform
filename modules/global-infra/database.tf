resource "aws_security_group" "mysql-sg" {
  name        = "mysql-sg"
  description = "To control the database traffic"
  vpc_id      = aws_vpc.global-infra.id

  ingress {
    description     = "allow connection to the database instance on port 3306"
    from_port       = 0
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks-cluster-security_group]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}

resource "aws_iam_role" "rds-cluster" {
  name = "rds-Cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "rds-cluster" {
  statement {
    actions = ["*"]
    resources = [ "*" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.aws-account}:root"]
    }    
  }
  statement {
    sid = "Kms encryption"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [ "*" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.aws-account}:role/${aws_iam_role.rds-cluster.name}"]
    }
  }
}


# resource "aws_iam_role_policy_attachment" "rds-Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
#   role       = aws_iam_role.rds-cluster.name
# }

resource "aws_kms_key" "rds-cluster" {
  description             = "KMS key for the ${var.env} rds cluster"
  deletion_window_in_days = 7
  tags = { 
    name = "${var.module-name}-${var.env}"
  }
  policy = data.aws_iam_policy_document.rds-cluster.json
}

resource "aws_kms_alias" "eks-cluster" {
  name          = "alias/${var.module-name}-${var.env}"
  target_key_id = aws_kms_key.rds-cluster.id
}


data "aws_ssm_parameter" "rds-master-password" {
  name = "dev-rds-master-password"
}

resource "aws_db_subnet_group" "rds-cluster" {
  name       = "rds-cluster"
  subnet_ids = [for k,v in aws_subnet.private-global-infra: v.id]
}


/*----------------Cluster RDS ---------------*/
#-----------------------------------------------

# 
# resource "aws_db_instance" "mysql" {
#   allocated_storage = 20
#   backup_retention_period = 7
#   backup_window = "03:30-06:00"
#   ca_cert_identifier = "rds-ca-rsa4096-g1"#aws_acmpca_certificate.rds-cluster.id
#   db_name = "shoppingPortal"
#   db_subnet_group_name = aws_db_subnet_group.rds-cluster.name
#   deletion_protection = false # Set to true for production environment
#   engine = "mysql"
#   engine_version = "8.0"
#   identifier = "mysql-${var.env}"
#   instance_class = "db.t3.micro"
#   kms_key_id = aws_kms_key.rds-cluster.arn
#   maintenance_window = "sat:23:30-sun:03:00"
#   multi_az = false
#   network_type = "IPV4"
#   password = data.aws_ssm_parameter.rds-master-password.value
#   skip_final_snapshot = true
#   storage_encrypted = true
#   username = "admin${var.env}"
#   vpc_security_group_ids = [aws_security_group.mysql-sg.id]
# }

# resource "aws_rds_cluster" "mysql" {
#   allocated_storage = 20
#   db_subnet_group_name = aws_db_subnet_group.rds-cluster.name
#   availability_zones =  [for k,v in var.private-subnets: v.AZ] #concat([for k,v in var.private-subnets: v.AZ],["ca-central-1d"])#[aws_subnet.private-global-infra["subnet1"].id]
#   backup_retention_period = 7
#   cluster_identifier = "${var.module-name}-${var.env}"
#   database_name = "defaultDatabase"
#   db_cluster_instance_class = "db.md5.xlarge"
#   deletion_protection = false
#   iam_roles = [aws_iam_role.rds-cluster.arn]

#   engine = "mysql" 
#   engine_mode = "provisioned"

#   skip_final_snapshot = true
#   final_snapshot_identifier = random_string.random.id

#   iam_database_authentication_enabled = false

#   storage_encrypted = true
#   kms_key_id = aws_kms_key.rds-cluster.arn

#   master_password = data.aws_ssm_parameter.rds-master-password.value
#   master_username = "admin${var.env}"
#   network_type = "IPV4"

#   # preferred_maintenance_window = "sat:23:30-sun:03:00"
#   # preferred_backup_window = "03:30-06:00"

#   vpc_security_group_ids = [aws_security_group.mysql-sg.id]
#   tags = {
#     name = "${var.module-name}-${var.env}"
#     env = var.env
#   }
# }

/*---------Database instance to launch in RDS cluster ---------*/
# resource "aws_rds_cluster_instance" "mysql" {
# #   allocated_storage = 10
#   db_subnet_group_name = aws_db_subnet_group.rds-cluster.name
#   # availability_zones =  [for k,v in var.private-subnets: v.AZ]#[aws_subnet.private-global-infra["subnet1"].id]
  
#   ca_cert_identifier = aws_acmpca_certificate.rds-cluster.id
#   cluster_identifier = aws_rds_cluster.mysql.cluster_identifier

#   instance_class = aws_rds_cluster.mysql.db_cluster_instance_class
#   engine =  aws_rds_cluster.mysql.engine
#   engine_version = aws_rds_cluster.mysql.engine_version
#   identifier = "${var.module-name}-${var.env}"

#   performance_insights_enabled = false

#   preferred_maintenance_window = "sat:23:30-sun:03:00"
#   # preferred_backup_window = "03:30-06:00"

#   tags = {
#     name = "${var.module-name}-${var.env}"
#     env = var.env
#   }
# }