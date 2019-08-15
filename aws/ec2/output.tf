output "app_instance_public_ip" {
  value = "${aws_instance.app.public_ip}"
}

output "app_instance_public_dns" {
  value = "${aws_instance.app.public_dns}"
}
