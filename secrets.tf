# secrets management stuff
# credstash: https://github.com/fugue/credstash

resource "aws_kms_key" "credstash" {
  description             = "${var.name} ${var.project} credstash"
  deletion_window_in_days = 30
  tags = {
    Name        = "${var.name} credstash"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_kms_alias" "credstash" {
  name          = "alias/${var.project}_${var.name}_credstash_${var.environment}"
  target_key_id = aws_kms_key.credstash.key_id
}

# construct the dynamodb database that credstash uses
# adopted from https://github.com/fugue/credstash/blob/4df7e2c832efe2b2bccdbc80be65923cccf6fd24/credstash.py
# L574+

resource "aws_dynamodb_table" "credstash" {
  name         = "${var.name}_${var.project}_credential_store_${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "name"
  range_key    = "version"

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "version"
    type = "S"
  }

  # TODO: need to think about this because documentation says it takes up to 10
  # minutes to enable this. perhaps key it so production only?

  point_in_time_recovery {
    enabled = false
  }

  tags = {
    Name        = "credstash ${var.name}"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
