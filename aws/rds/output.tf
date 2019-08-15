output "db_endpoint" {
  value = "${aws_db_instance.app.endpoint}"
}

output "db_name" {
  value = "${aws_db_instance.app.name}"
}
output "db_username" {
  value = "${aws_db_instance.app.username}"
}

output "db_password" {
  value = "${aws_db_instance.app.password}"
}
