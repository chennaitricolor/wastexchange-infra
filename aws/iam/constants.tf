data "aws_caller_identity" "current" {}

locals {
  tf_state_bucket     = "wex-terraform-state-1564297303"
  tf_state_lock_table = "wex-terraform-state-lock"
  account_number      = "${data.aws_caller_identity.current.account_id}"
}

