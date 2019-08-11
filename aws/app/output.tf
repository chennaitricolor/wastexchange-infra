output "app_instance_public_ip" {
  value = "${aws_instance.app.public_ip}"
}

output "app_instance_public_dns" {
  value = "${aws_instance.app.public_dns}"
}

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
